---
name: pisanie-pracy
description: >-
  Redaguje pracę inżynierską Wydziału Nauk Inżynieryjnych ANS w Nowym Sączu
  według zasad wydziału (2026) i wzoru strony tytułowej. Używaj przy pisaniu
  lub poprawie rozdziałów, wstępu, celu i zakresu, metodyki projektu,
  projektu i implementacji, podsumowania, bibliografii, cytowań harwardzkich,
  rysunków, tabel, wzorów oraz plików praca/**/*.typ i praca/literatura.bib.
---

# Pisanie pracy inżynierskiej WI ANS

Skład jest w szablonie. Tu obowiązuje treść i redakcja. Szczegóły cytowań, rysunków i tabel: [reference.md](reference.md).

## Zanim napiszesz

1. To repozytorium jest pod **pracę inżynierską** (projekt + implementacja, IV.2 i V.2 poradnika 2026).
2. Przeczytaj sąsiednie rozdziały i nie powtarzaj tych samych treści.
3. Nowy rozdział: katalog `praca/<NN-nazwa>/` z plikiem `<NN-nazwa>.typ` i `sources/` (np. `01-przeglad/01-przeglad.typ`), potem `#include` w `main.typ`. Załącznik: `06-zalaczniki/<NN-nazwa>/<NN-nazwa>.typ`.
4. Nie dopisuj streszczenia ani słów kluczowych do PDF. Idą do ASAP.

## Układ treści (inżynierska)

Kolejność w `main.typ`: strona tytułowa, spis treści, treść, bibliografia, spis tabel, spis rysunków, spis załączników, załączniki.

| Element poradnika (IV.2 / V.2) | Katalog w `praca/` |
| --- | --- |
| Wstęp (obszar, problemy — bez celu i bez genezy szczegółowej) | `00-wstep/` — `#wstep[...]` |
| Przegląd rozwiązań i technologii (w tym kryteria oceny u innych) | `01-przeglad/` |
| Cel i zakres pracy (obowiązkowy; geneza, cel, zakres, kryteria) | `02-cel-i-zakres/` |
| Metodyka projektu i weryfikacji (narzędzia, pomiar kryteriów, odtwarzalność) | `03-metodyka/` |
| Projekt, implementacja i weryfikacja, wkład własny | `04-projekt-i-wyniki/` |
| Podsumowanie (obowiązkowe; co zrobiono) | `05-podsumowanie/` |
| Załączniki | `06-zalaczniki/<NN-nazwa>/<NN-nazwa>.typ` |

Rozdział „Metodyka badań” z poradnika jest obowiązkowy w pracy **badawczej** (typowa magisterska), nie w inżynierskiej. W inżynierskiej uzasadnia się metody, techniki i narzędzia projektu.

- **Wstęp** bez numeru rozdziału.
- **Cel i zakres pracy** oraz **Podsumowanie** są obowiązkowe.
- Numeracja arabska do trzech stopni (`1.`, `1.1.`, `1.1.1.` w szablonie). Bez kropki na końcu **tytułu** rozdziału.
- Zakaz jednego podrozdziału w rozdziale. Albo co najmniej dwa, albo żaden.
- Rozdział ma mieć kilka stron i nie może składać się z samych rysunków, tabel albo wzorów.
- W podsumowaniu wprost zapisz, co autor zrobił, ocenę realizacji celu, uproszczony opis zaprojektowanego systemu oraz wytyczne do dalszych działań (IV.2, praca projektowa). Wnioski tylko z treści pracy.

Treść merytoryczna inżynierska: geneza w rozdziale celu, przegląd metod i narzędzi, opis projektu i implementacji z wkładem własnym, prezentacja działania rozwiązania, krytyczne podsumowanie.

Kryteria oceny systemu należy najpierw zbadać u innych (przegląd, dokumentacja platform), następnie wyznaczyć progi w „Cel i zakres pracy”, opisać pomiar w metodyce i zestawić wyniki w rozdziale projektowym. Przy testach obciążeniowych liczby (nadawcy, odbiorcy, rampa, progi) ustaw w `praca/parametry.yaml` i odwołuj się przez `praca/parametry.typ`, nie wpisuj ich ręcznie w rozdziałach.

## Język

- Forma bezosobowa: „przeprowadzono”, „zastosowano”, „wykazano”.
- Bez stylu publicystycznego, kolokwializmów i żargonu.
- Skrót przy pierwszym użyciu: `ANS (Akademia Nauk Stosowanych w Nowym Sączu)`, `CPU (ang. Central Processing Unit)`.
- Wyróżnienia oszczędnie i jednym sposobem w całej pracy.
- Zdania krótkie. Nie zaczynaj zdania od liczby.
- Nie wydłużaj tekstu sztucznie: bez zmiany marginesów, interlinii i odstępów między znakami.

## Cytowania

Styl harwardzki w tekście, nie w przypisie. Przypis dolny tylko na dygresję.

- `(Nowak, 2014)`, cytat: `(Nowak, 2014, s. 34)`.
- Dwóch autorów: zawsze oba nazwiska. Trzech: pierwszy raz wszyscy, potem `Nowak i in.`. Czterech i więcej: od razu `i in.`.
- Kilka prac w jednym nawiasie: alfabetycznie, średnik. Ten sam autor: `(Nowak, 2001, 2003)`. Ten sam rok: `2005a`, `2005b`.
- Cytat krótszy niż 40 słów w „cudzysłowie”. Dłuższy: `#cytat[...]`, bez cudzysłowu. Cytaty dosłowne poniżej 5% pracy.
- W `praca/literatura.bib` tylko pozycje przywołane w tekście. Nie cytuj prac niepublicznych (magisteria, ekspertyzy, przekazy ustne).
- Nie wymyślaj źródeł, stron ani danych. Brak pozycji zgłoś wprost.
- **Weryfikacja ręczna:** każdy wpis w `literatura.bib` i `netografia.bib` sprawdź pod kątem autora, roku, tytułu, stron i dostępności; treść przy każdym `#cite` porównaj ze źródłem. Przed oddaniem przejdź bibliografię i odsyłacze w obie strony; adresy WWW otwórz w przeglądarce i uzupełnij datę dostępu.

## Obiekty

Najpierw odesłanie w tekście, potem obiekt. Rozdział nie zaczyna się od rysunku, tabeli ani wzoru. Każdy obiekt trzeba zinterpretować, nie tylko wstawić.

Rysunki (także wykresy, schematy, zdjęcia): `#rysunek(image("sources/plik.png"), [Tytuł]) <etykieta>`, w tekście `na #rys(<etykieta>)`. Źródło cudze podaj zamiast domyślnego „opracowanie własne”.
Tabele: `#tabela([Tytuł], table(...)) <etykieta>`, w tekście `w #tab(<etykieta>)`.
Wzór: `#wzor(objasnienia: [gdzie: ...])[$ ... $ <etykieta>]`, w tekście `(@etykieta)`.

Szablony zapisów bibliograficznych i reguły liczb, jednostek oraz komórek tabel: [reference.md](reference.md).

## Po napisaniu rozdziału

- [ ] Cel rozdziału nie dubluje wstępu, celu pracy ani podsumowania.
- [ ] Każdy rysunek i tabela ma wcześniejsze odesłanie i komentarz.
- [ ] Każde twierdzenie z literatury ma odsyłacz, a klucz jest w `praca/literatura.bib`.
- [ ] Brak jednego osieroconego podrozdziału i braku poziomu głębszego niż 1.1.1.
- [ ] W rozdziale projektowym widać wkład własny (projekt, implementacja, weryfikacja).
- [ ] Podsumowanie mówi wprost, co zostało zrobione, zawiera uproszczony opis systemu i wytyczne na przyszłość.
- [ ] Kryteria z przeglądu widać w celu, metodyce i wynikach; cytowania zweryfikowane ręcznie.
