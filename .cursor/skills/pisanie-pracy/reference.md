# Zasady redakcyjne WI ANS

Źródło: „Zasady pisania prac dyplomowych na Wydziale Nauk Inżynieryjnych ANS w Nowym Sączu” (2026) oraz wzór strony tytułowej. Skład realizuje szablon; tego pliku nie wklejaj do pracy.

## Strona tytułowa

Pola tylko te: Akademia Nauk Stosowanych w Nowym Sączu, wydział, „PRACA DYPLOMOWA”, tytuł, autor, kierunek, numer albumu, promotor, akceptacja promotora (data i podpis), miejscowość i rok. Ustawiane w `main.typ` przez `praca.with`. Nie dopisuj specjalności ani rodzaju pracy (inżynierska/magisterska) — wzór ich nie ma.

## Odsyłacze w tekście

| Autorzy | Pierwszy raz | Kolejne |
| --- | --- | --- |
| 1 | `(Nowak, 2010)` | tak samo |
| 2 | `(Nowak, Kowalski, 2010)` | tak samo |
| 3 | `(Nowak, Kowalski, Iksińska, 2010)` | `(Nowak i in., 2010)` |
| 4+ | `(Nowak i in., 2011)` | tak samo |
| Instytucja | `(Narodowe Centrum Nauki, 2011)` | `(NCN, 2011)` |

- W jednym nawiasie: alfabetycznie, średnik. Ten sam autor, różne lata: `(Nowak, 2001, 2003)`; „w druku” na końcu.
- Ten sam autor i rok: `2005a`, `2005b`, także w bibliografii, kolejność alfabetyczna tytułów.
- Cytat: `(Nazwisko, 2012, s. 33–34)`.
- Forma narracyjna: `Herlinger (1974) przyjął…` — w Typst `#cite(<klucz>, form: "prose")`.
- Bez autora: pierwsze słowa tytułu, nazwa wydawcy albo „Anonim”, i tak samo w bibliografii.
- Z drugiej ręki: `(Nowak, 2001, za Kowalską, 2000)` i obie pozycje w bibliografii.
- Źródło tylko elektroniczne można oznaczyć dopiskiem „Online”.

## Bibliografia

Alfabetycznie. Tytuł pracy kursywą. Adresy URL w osobnej grupie na końcu, z datą dostępu, wyrównane do lewej (szablon składa je w jednym wykazie, format wpisu z datą pobrania jest obowiązkowy).

- Książka: `Nazwisko, X. (rok). Tytuł książki. Miejsce: Wydawnictwo.`
- Pod redakcją: `Nazwisko, X. (red.). (rok). Tytuł książki. Miejsce: Wydawnictwo.`
- Rozdział: `Nazwisko, X. (rok). Tytuł rozdziału. W: Y. Nazwisko (red.), Tytuł książki (s. początek–koniec). Miejsce: Wydawnictwo.`
- Artykuł: `Nazwisko, X.; Nazwisko, Y. (rok). Tytuł artykułu. Tytuł Czasopisma, rocznik (zeszyt), strony.`
- Norma: `PN-ISO 690-2:1999. (1999). Tytuł normy.`
- WWW: `Nazwisko, X. (rok). Tytuł. Organizacja. Pobrane z: adres, data pobrania [dd.mm.rrrr].`

Literatura ma być aktualna, z okresu pisania pracy, i zróżnicowana (książki, normy, akty, artykuły, raporty).

## Rysunki

Wykres, schemat, fotografia i mapa to rysunek. Numeracja ciągła w całej pracy.

- Podpis pod rysunkiem, wyśrodkowany, 11 pkt: `Rysunek 12. Przebieg zmian temperatury`. Kropka po numerze, bez kropki na końcu tytułu.
- Źródło pod tytułem, 10 pkt, kursywa, do środka: `[źródło: opracowanie własne]` albo `[źródło: opracowanie własne na podstawie Guziński 1994]`.
- Osie i wartości: 10 pkt, czarne, bez pogrubienia, z jednostkami. Kilka serii: legenda.
- Jedna pusta linia przed i po rysunku z podpisem. Rysunek wyśrodkowany.
- W tekście, zanim obiekt się pojawi: „jak pokazano na rysunku X”, „(rysunek X)”.

## Tabele

Numeracja ciągła. Podpis nad tabelą, 11 pkt, dwa wiersze, bez kropki po numerze i na końcu tytułu:

```text
Tabela 1
Średnie wartości współczynnika jakości
```

- Treść tabeli: 10 pkt, czarna, bez pogrubień. Tabela wyśrodkowana.
- Źródło pod tabelą, 10 pkt, kursywa: `Źródło: opracowanie własne` albo `Źródło: opracowanie własne na podstawie ….`.
- Uwagi pod tabelą, 10 pkt, do lewej.
- Każda komórka wypełniona. Poniżej dokładności pomiaru: `0`. Zjawisko nie występuje: `-`. Brak pomiaru: `b.d.` albo `n.o.`.
- Lata: `2014` (bez „r.”). Kwartały: `I`, `IV`. Miesiące pełną nazwą: `maj`.
- Tej samej serii liczb nie dawaj i w tabeli, i na wykresie.

## Liczby i wzory

- Przecinek dziesiętny: `3,14`. Tysiące spacją nierozdzielającą: `100 000`.
- Jednostka SI od liczby spacją nierozdzielającą: `164 cm`, `26 g`. Wyjątki: `23%`, `10°C`.
- Godzina: `h` (nie „godz.”). Sekunda: `s` (nie „sek.”).
- Symbol objaśnij przy pierwszym użyciu. Wzór numerowany z prawej `(4)`, pod spodem `gdzie:` ze znaczeniem i jednostką.
- W tekście przywołanie numeru w nawiasie: „ze wzoru (4)”.
- Trzy liczby znaczące, gdy więcej cyfr nie wynika z dokładności. Duże i małe wartości można zapisać jako `2,6 · 10^6`.

## Wyliczenia

Jeden sposób w całej pracy. Pozycja od wielkiej litery kończy się kropką. Od małej litery — średnikiem albo przecinkiem, konsekwentnie. Nie schodź poniżej trzeciego poziomu listy.
