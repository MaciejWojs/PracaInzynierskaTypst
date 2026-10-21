# Diagramy architektury (Mermaid)

Uzupełnienie do `wdrozenie-i-infrastruktura.md`. Diagramy robocze, przed wstawieniem do pracy trzeba je odtworzyć jako rysunki z podpisem i odesłaniem w tekście.

## 1. Układ repozytoriów i przepływ wdrożenia

```mermaid
flowchart LR
    dev([Autor]) -->|commit| be[Repo backend]
    dev -->|commit| fe[Repo frontend]
    dev -->|PR| iac[Repo iac<br/>terraform, argocd, charts]

    be -->|GitHub Actions: build, test| ghcr[(ghcr.io)]
    fe -->|GitHub Actions: build, test| ghcr
    be -->|commit nowego tagu| iac
    fe -->|commit nowego tagu| iac

    iac -->|plan, apply przez OIDC| aws[AWS]
    iac -->|pobiera stan| argo[Argo CD w EKS]
    argo -->|synchronizacja| k8s[Zasoby w klastrze EKS]
    ghcr -->|pull obrazu| k8s
```

## 2. Architektura platformy w AWS

```mermaid
flowchart TB
    subgraph Klienci
        nad[Nadawca<br/>OBS lub ffmpeg]
        wid[Widz<br/>przegladarka]
    end

    subgraph AWS
        ivs[Amazon IVS<br/>ingest, transkodowanie, dostarczanie]
        s3[(S3<br/>nagrania i pliki)]
        subgraph VPC
            waf[WAF]
            alb[ALB]
            subgraph EKS
                fe[Frontend]
                api[Backend<br/>API, WebSocket czat, SSE]
                redis[(Redis lub Valkey)]
                prom[Prometheus]
                graf[Grafana]
            end
        end
        sm[Secrets Manager]
    end

    nad -->|RTMPS| ivs
    ivs -->|HLS| wid
    wid -->|HTTPS, WebSocket, SSE| waf --> alb
    alb --> fe
    alb --> api
    api --> redis
    api -->|zarzadzanie kanalami| ivs
    api --> s3
    prom -.->|metryki| api
    graf --> prom
    sm -.->|External Secrets| api
```

## 3. Warstwy infrastruktury i granica odpowiedzialności

```mermaid
flowchart TB
    subgraph TF[Terraform - repo iac]
        tfb[Warstwa bazowa<br/>VPC, EKS, IAM]
        tfp[Warstwa platformy<br/>IVS, S3, role IRSA, sekrety jako zasoby]
        boot[Bootstrap klastra<br/>Argo CD, ESO, kontrolery]
    end

    subgraph ARGO[Argo CD - repo iac]
        root[App of apps<br/>platform]
        app[Aplikacje: backend, frontend]
        mon[Monitoring: Prometheus, Grafana]
        eso[External Secrets Operator]
    end

    tfb --> tfp
    tfb --> boot
    boot --> root
    root --> app
    root --> mon
    root --> eso

    aws[(AWS)] --- tfb
    aws --- tfp
    k8s[(Klaster EKS)] --- ARGO
```

## 4. Sekrety i pobieranie obrazu z GHCR

```mermaid
sequenceDiagram
    participant Admin as Autor
    participant SM as AWS Secrets Manager
    participant ESO as External Secrets Operator
    participant K8s as API Kubernetes
    participant Kubelet as Kubelet (wezel)
    participant GHCR as ghcr.io

    Admin->>SM: utworzenie sekretu z tokenem (poza Terraform)
    ESO->>SM: odczyt przez rola IAM (Pod Identity lub IRSA)
    ESO->>K8s: utworzenie Secret typu dockerconfigjson
    K8s->>Kubelet: Pod z imagePullSecrets
    Kubelet->>GHCR: pull obrazu z tokenem read:packages
    GHCR-->>Kubelet: warstwy obrazu
```

## 5. Terraform w GitHub Actions i wykrywanie dryfu

```mermaid
flowchart LR
    pr[Pull request w iac] --> chk[fmt, validate, tflint]
    chk --> plan[terraform plan<br/>komentarz w PR]
    plan --> rev{Zatwierdzenie}
    rev -->|tak| apply[terraform apply<br/>reczny lub po merge]
    apply --> aws[AWS]
    apply --> st[(Stan w S3<br/>z blokada)]

    cron([Harmonogram]) --> dplan[terraform plan<br/>-detailed-exitcode]
    st --> dplan
    dplan --> d{Kod wyjscia 2?}
    d -->|tak| issue[Issue lub powiadomienie<br/>o dryfie]
    d -->|nie| ok[Brak dryfu]

    gha[GitHub Actions] -. OIDC, rola IAM .-> aws
```

## 6. Skalowanie w klastrze

```mermaid
flowchart TB
    wid[Widzowie] --> alb[ALB<br/>target-type ip]
    alb --> p1[Pod backend 1]
    alb --> p2[Pod backend 2]
    alb --> pn[Pod backend N]

    hpa[HPA<br/>skaluje pody wg metryk] -.-> p1
    hpa -.-> p2
    hpa -.-> pn

    pn -->|brak miejsca na wezlach| kar[Karpenter lub Cluster Autoscaler<br/>dodaje wezly]
    kar --> node[Nowy wezel EC2]
    node -->|pull obrazu| ghcr[(ghcr.io)]

    p1 --> redis[(Redis)]
    p2 --> redis
    pn --> redis
```

## 7. Wejscie ruchu: WebSocket i SSE

```mermaid
sequenceDiagram
    participant W as Widz
    participant A as ALB
    participant P as Pod backend
    participant R as Redis

    W->>A: HTTP Upgrade do WebSocket
    A->>P: polaczenie przypiete do jednego poda
    W->>P: wiadomosc czatu
    P->>R: publikacja w kanale
    R-->>P: rozeslanie do podow
    P-->>W: wiadomosc do widzow polaczonych z tym podem
    Note over A,P: idle timeout ALB wiekszy niz interwal ping
```
