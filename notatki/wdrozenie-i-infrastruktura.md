# Notatki: wdrożenie i infrastruktura platformy

Notatki robocze (nie wchodzą do PDF). Ustalenia z rozmowy, do przeniesienia do pracy po implementacji.
Obrona: styczeń/luty. Implementacja od zera, treść pracy równolegle.

## 1. Decyzje projektowe

| Obszar | Decyzja |
| --- | --- |
| Obraz wideo | Amazon IVS (limity w `praca/parametry.yaml`) |
| Orkiestracja | Kubernetes na AWS (EKS) |
| IaC | Terraform, repozytorium na GitHub |
| Wdrożenie | Argo CD (GitOps), Helm |
| CI | GitHub Actions (Jenkins prawdopodobnie nie) |
| Rejestr obrazów | `ghcr.io` |
| Sekrety | AWS Secrets Manager lub Parameter Store plus External Secrets Operator |
| Wykrywanie dryfu | Etap 1: cykliczny `terraform plan`; etap 2 (opcjonalnie): kontroler w klastrze |

Terraform, Argo CD i CI są narzędziami pomocniczymi, nie celem pracy.

## 2. Układ repozytoriów

| Repozytorium | Zawartość |
| --- | --- |
| `backend` | kod, Dockerfile, testy, workflow CI |
| `frontend` | kod, Dockerfile lub build statyczny, CI |
| `iac` | `terraform/`, `argocd/` (aplikacje, ApplicationSet), `charts/` lub `deploy/` |

Przepływ: commit w `backend`/`frontend`, CI buduje obraz i wypycha do GHCR, CI commituje nowy tag do `iac`, Argo CD synchronizuje klaster.
Źródłem prawdy o stanie klastra jest `iac`. Commit aplikacji nie może uruchamiać `terraform apply` (filtry ścieżek).

## 3. GitOps i Argo CD

- Argo CD uzgadnia stan klastra z Gitem; rollback to `git revert`.
- Helm: chart aplikacji plus `values-<środowisko>.yaml`.
- App-of-apps: stała lista komponentów (aplikacja, Redis, monitoring). Prosty wzorzec.
- ApplicationSet: dopiero przy wielu środowiskach lub klastrach (generator Git po `envs/*`).
- Automatyczna synchronizacja z `prune` i `selfHeal` na środowisku testowym.
- Jenkins jako wdrażający odradzany (brak uzgadniania, poświadczenia do klastra, trudniejszy audyt).

Granica odpowiedzialności:
- Terraform: zasoby AWS i bootstrap klastra (Argo CD, kontrolery).
- Argo CD: wszystko, co działa w klastrze. Nie instalować aplikacji przez Terraform (konflikt dwóch narzędzi).

## 4. Terraform i GitHub Actions

- Uwierzytelnianie do AWS przez OIDC (rola IAM), bez długoterminowych kluczy.
- Pull request: `terraform fmt`, `validate`, `plan` (wynik w komentarzu).
- `apply`: ręczny (`workflow_dispatch`) albo po merge z zatwierdzeniem (GitHub Environments).
- Stan zdalny w S3 z blokadą; `*.tfstate` i `*.tfvars` z sekretami w `.gitignore`.
- Rozdzielone stany: warstwa bazowa (VPC, EKS) i warstwa platformy (IVS, S3 itd.).
- Opcjonalnie: `tflint`, `checkov` lub `trivy config`.
- `terraform destroy` po testach (koszty, odtwarzalność).
- Przy publicznym repozytorium: ID konta AWS i nazwy zasobów wynieść do zmiennych.

## 5. Wykrywanie dryfu infrastruktury

| Opcja | Uwagi |
| --- | --- |
| Cykliczny `plan` w GitHub Actions | Najprostsze; `-detailed-exitcode`, kod 2 oznacza dryf (issue lub powiadomienie). Tylko wykrywa. |
| Tofu Controller (Flux) | Terraform jako CR, wykrywa dryf; wymaga Flux obok Argo CD, niepewne wsparcie projektu (zweryfikować). |
| Atlantis | `plan`/`apply` z komentarzy w PR; dryf tylko z cyklicznym planem. |
| Crossplane lub ACK | Zasoby AWS jako CR, ciągłe uzgadnianie; zastępuje Terraform, większa krzywa uczenia. |
| SaaS (HCP Terraform, Spacelift, env0) | Wbudowany dryf; zewnętrzna usługa. |

Rekomendacja: zacząć od cyklicznego `plan`; kontroler w klastrze tylko jeśli zostanie czas (do wytycznych na przyszłość, jeśli nie).
Uwagi:
- Kontroler z Terraform wymaga szerokich uprawnień IAM: osobna rola z minimum uprawnień.
- Klaster nie powinien zarządzać własnym bootstrapem (EKS, VPC).
- Na czas testów obciążenia tryb „tylko wykryj”, bez auto-apply.

## 6. Rejestr obrazów GHCR

- Push z CI: `GITHUB_TOKEN` z `packages: write`.
- Pull z klastra (pakiety prywatne): `imagePullSecret` (`kubernetes.io/dockerconfigjson`) z tokenem tylko do odczytu (`read:packages`); sprawdzić aktualne opcje (fine-grained token, GitHub App).
- Pakiety publiczne: bez tokenu, ale obraz nie może zawierać nic poufnego.
- Pobieranie idzie przez internet (NAT Gateway, koszt i czas startu podów); małe obrazy, stałe tagi, `imagePullPolicy: IfNotPresent`.
- Opcjonalnie ECR pull-through cache.
- Token wygasa: zaplanować datę i przypomnienie (typowa przyczyna `ImagePullBackOff`).

## 7. Sekrety w AWS

Układ: Secrets Manager (lub Parameter Store `SecureString`) -> External Secrets Operator -> `Secret` w klastrze (w tym `dockerconfigjson`) -> kubelet pobiera obraz z GHCR.

- W `iac` tylko definicje `ExternalSecret`, bez wartości.
- Wartości tworzyć poza Terraform (inaczej trafią do stanu); Terraform zarządza zasobem i uprawnieniami IAM.
- ESO: rola IAM (IRSA lub EKS Pod Identity) ograniczona prefiksem, np. `platforma/*`.
- Osobna rola dla każdego komponentu.
- Parameter Store tańszy, bez rotacji; Secrets Manager z rotacją i kosztem za sekret. Wybór uzasadnić w pracy.
- Argo CD potrzebuje poświadczeń do prywatnego repozytorium przed ESO: utworzyć jednorazowo przy bootstrapie (deploy key tylko do odczytu lub GitHub App).
- Włączyć GitHub secret scanning, sprawdzić historię Gita pod kątem wycieków.
- Alternatywy: Sealed Secrets, SOPS, Secrets Store CSI Driver (mniej dopasowane).

## 8. Skalowanie Kubernetes w AWS (skrót)

- HPA skaluje pody; Karpenter lub Cluster Autoscaler skaluje węzły; VPA zmienia zasoby podów.
- Komunikacja przez Service (ClusterIP, kube-proxy): lokalizacja podu nie ma znaczenia.
- VPC CNI: pody mają adresy VPC; ALB `target-type: ip` kieruje wprost do podów.
- Balansowanie per połączenie: WebSocket i SSE przylegają do jednego podu.
- Limit podów na węzeł zależy od typu instancji (ENI).
- ALB: `idle_timeout` powyżej interwału pingów WebSocket (domyślnie 60 s).

## 9. Harmonogram (orientacyjny, ~12 tygodni plus bufor)

1. Tydz. 1-2: spike AWS: Service Quotas (IVS), kanał IVS, nadawanie z OBS/ffmpeg i odtwarzanie, AWS Budgets.
2. Tydz. 2-4: Terraform: VPC, EKS, IVS, S3, zdalny stan, `destroy`.
3. Tydz. 4-6: Argo CD, chart Helm, app-of-apps, ESO, AWS Load Balancer Controller, Karpenter.
4. Tydz. 6-10: backend (czat WebSocket, powiadomienia SSE, API), integracja IVS, frontend.
5. Tydz. 10-12: obciążenie 30/300 (rampa 10/100, 20/200, 30/300), Prometheus i Grafana; zapas na powtórzenie.
6. Ostatnie 4-6 tyg.: tekst i poprawki (notatki, zrzuty i wykresy zbierać na bieżąco).

MVP: jeden nadawca, widz, czat, metryki; skalowanie do 30/300 jako etap końcowy. Przy opóźnieniach mniejszy profil w `parametry.yaml` po zgodzie promotora.

## 10. Pułapki AWS

- IAM i uprawnienia: najczęstsza strata czasu (IRSA lub Pod Identity, minimalne uprawnienia).
- Limity IP w VPC CNI na małych instancjach.
- Koszty: NAT Gateway, ALB, węzły EKS, godziny IVS; budżety od pierwszego dnia.
- Transfer między AZ: dwie strefy wystarczą.
- Generatory obciążenia na osobnych węzłach (Spot), w tym samym regionie, wyłączane po teście.
- Region z IVS (np. `eu-west-1`, `us-east-1`); zmiana regionu później to przebudowa.
- Nowe konto: limity mogą być niższe, zgłoszenie podniesienia trwa.

## 11. Zmiany do wprowadzenia w pracy

- `02-cel-i-zakres`: Terraform, Argo CD i CI jako narzędzia pomocnicze (nie cel); w „Zakresie poza pracą” zostają Loki, wiele klastrów, ewentualnie kontroler dryfu w klastrze; Jenkins usunąć, jeśli nie będzie użyty.
- `03-metodyka`: narzędzia wdrożeniowe i układ repozytoriów w jednym akapicie.
- `04-projekt-i-wyniki`: podrozdział „Wdrożenie i infrastruktura” z diagramem (commit, CI, GHCR, `iac`, Argo CD, EKS) oraz opis sekretów (Secrets Manager, ESO, imagePullSecret) i wykrywania dryfu.
- `05-podsumowanie`: wytyczne na przyszłość (ApplicationSet, kontroler dryfu, Loki).
- Bibliografia: dokumentacja Terraform, Argo CD, GitHub Actions OIDC, GHCR, External Secrets Operator, EKS Pod Identity (z datą dostępu, weryfikacja ręczna).
- Sprawdzić w zasadach wydziału, czy wymagane jest archiwum z kodem; link do repozytoriów w pracy.
- Zmiany zakresu uzgodnić z promotorem (kryteria oceny wynikają z celu).
