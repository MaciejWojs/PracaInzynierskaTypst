// Praca inżynierska WI ANS — plik główny.
// Kompilacja: typst compile main.typ
//
// Układ treści (poradnik 2026, V.2): 00-wstep → 01-przeglad → 02-cel-i-zakres →
// 03-metodyka → 04-projekt-i-wyniki → 05-podsumowanie → bibliografia → spisy →
// 06-zalaczniki.
//
// Każdy rozdział: praca/<NN-nazwa>/<NN-nazwa>.typ oraz praca/<NN-nazwa>/sources/.
// Załącznik: praca/06-zalaczniki/<NN-nazwa>/<NN-nazwa>.typ.
// Obraz z rozdziału: #rysunek(image("sources/nazwa.png", width: 12cm), [Tytuł]) <etykieta>
// Ścieżka sources/ jest liczona od pliku rozdziału, nie od main.typ.
// Szablon składu jest w szablon/, bibliografia w praca/literatura.bib.
// Liczby testów obciążenia i progi kryteriów: praca/parametry.yaml (przez import w rozdziałach).
// Streszczenie i słowa kluczowe trafiają do ASAP, nie do tego pliku.
// Egzemplarz archiwalny drukuje się dwustronnie, bez oprawy.

#import "szablon/template.typ": (
  praca, bibliografia, spis-tresci, spis-tabel, spis-rysunkow, spis-zalacznikow,
)

#show: praca.with(
  tytul: "Budowa społecznościowej platformy wideo z obsługą strumieniowania w czasie rzeczywistym",
  autor: "Maciej Wójs",
  kierunek: "Informatyka Stosowana",
  nr-albumu: "33106",
  promotor: "mgr inż. Bulanda Nikodem",
  wydzial: "Wydział Nauk Inżynieryjnych",
  miejscowosc: "Nowy Sącz",
  rok: "2026",
)

#spis-tresci()

#include "praca/00-wstep/00-wstep.typ"
#include "praca/01-przeglad/01-przeglad.typ"
#include "praca/02-cel-i-zakres/02-cel-i-zakres.typ"
#include "praca/03-metodyka/03-metodyka.typ"
#include "praca/04-projekt-i-wyniki/04-projekt-i-wyniki.typ"
#include "praca/05-podsumowanie/05-podsumowanie.typ"

#bibliografia()
#spis-tabel()
#spis-rysunkow()
#spis-zalacznikow()

#include "praca/06-zalaczniki/01-pomiary/01-pomiary.typ"
