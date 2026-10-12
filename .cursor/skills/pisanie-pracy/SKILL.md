---
name: pisanie-pracy
description: >-
  Redaguje pracę dyplomową Wydziału Nauk Inżynieryjnych ANS w Nowym Sączu
  według zasad wydziału (2026) i wzoru strony tytułowej. Używaj przy pisaniu
  lub poprawie rozdziałów, wstępu, celu i zakresu, metodyki, podsumowania,
  bibliografii, cytowań harwardzkich, rysunków, tabel, wzorów oraz plików
  praca/**/*.typ i praca/literatura.bib.
---

# Pisanie pracy dyplomowej WI ANS

Skład jest w szablonie. Tu obowiązuje treść i redakcja. Szczegóły cytowań, rysunków i tabel: [reference.md](reference.md).

## Zanim napiszesz

1. Ustal, czy to praca inżynierska (projekt + implementacja), czy magisterska (badanie, nie sam przegląd teorii). Gdy z tekstu tego nie widać, nie zgaduj rodzaju wymogów.
2. Przeczytaj sąsiednie rozdziały i nie powtarzaj tych samych treści.
3. Nowy rozdział: katalog `praca/<nazwa>/` z `rozdzial.typ` i `sources/`, potem `#include` w `main.typ`.
4. Nie dopisuj streszczenia ani słów kluczowych do PDF. Idą do ASAP.

## Układ, którego nie wolno złamać

Kolejność: strona tytułowa, spis treści, treść, bibliografia, spis tabel, spis rysunków, spis załączników, załączniki.

- **Wstęp** bez numeru: obszar pracy i problemy. Cel jest w osobnym rozdziale.
- **Cel i zakres pracy** oraz **Podsumowanie** są obowiązkowe.
- **Metodyka badań** jest obowiązkowa w pracy badawczej.
- Numeracja arabska, najwyżej trzy stopnie (`1`, `1.1`, `1.1.1`). Bez kropki na końcu tytułu.
- Zakaz jednego podrozdziału w rozdziale. Albo co najmniej dwa, albo żaden.
- Rozdział ma mieć kilka stron i nie może składać się z samych rysunków, tabel albo wzorów.
- W podsumowaniu wprost zapisz, co autor zrobił. Wnioski tylko z treści pracy.

Inżynierska: geneza, cel, przegląd metod i narzędzi, opis projektu i implementacji z wkładem własnym, działanie rozwiązania, krytyczne podsumowanie.
Magisterska: problem badawczy, analiza literatury (nie streszczenia książek), metody, rozwiązanie albo przegląd z oceną użyteczności, część praktyczna. Nie może być wyłącznie teoretyczna.

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
- [ ] Podsumowanie, jeśli je ruszasz, mówi wprost, co zostało zrobione.
