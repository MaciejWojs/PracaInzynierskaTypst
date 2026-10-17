#import "/szablon/template.typ": tabela, tab
#import "/praca/parametry.typ": (
  profil-docelowy-z-rozkladem, rampa-skrot-slasha, zgodnosc-z-limitami,
  tabela-zalozenie-sesje, tabela-zalozenie-opoznienie, tabela-zalozenie-pierwsza-klatka,
  tabela-zalozenie-czat, tabela-zalozenie-api, tabela-zalozenie-odtworzenia,
  opoznienie-obrazu-max-s, czas-api-p95-max-ms, opoznienie-czatu-p95-max-ms,
  zrodlo-tabela-mierniki, profil-skrot,
)

= Cel i zakres pracy
Na podstawie przeglądu rozwiązań rynkowych i technologii określono, co ma zostać osiągnięte w pracy, w jakich granicach oraz według jakich kryteriów oceniony zostanie wynik. Sposób wykonania, czyli architektura, wybór konkretnych usług i szczegóły implementacji, opisano w rozdziale „Projekt, implementacja i weryfikacja”.

== Geneza pracy
Użytkownicy platform społecznościowych oczekują jednoczesnej transmisji wideo na żywo, interakcji w czacie i stabilnego odtwarzania na różnych urządzeniach. W dokumentacjach dużych serwisów widać rozdzielenie ścieżki obrazu od kanału czatu oraz publikowanie progów opóźnienia w trybach interaktywnych #cite(<youtube_latency>) #cite(<twitch_low_latency>). Zbudowanie własnej platformy wymaga połączenia warstwy aplikacyjnej z usługami multimedialnymi i mechanizmami czasu rzeczywistego, a także wykazania, że całość skaluje się wraz z liczbą nadawców i widzów. Jest to problem inżynierski o charakterze projektowym i implementacyjnym.

== Cel pracy
Celem pracy jest zaprojektowanie i zaimplementowanie społecznościowej platformy wideo z obsługą transmisji na żywo oraz wykazanie, że spełnia ona przyjęte kryteria funkcjonalne i wydajnościowe, w tym skalowanie do profilu obciążenia #profil-skrot (nadawcy/odbiorcy).

Cele szczegółowe:
- umożliwienie publikowania i odtwarzania transmisji na żywo z obrazem i dźwiękiem;
- zapewnienie funkcji społecznościowych: czatu, reakcji i powiadomień;
- zapis transmisji i udostępnianie nagrań w formie VOD (ang. _Video on Demand_);
- uzyskanie skalowania poziomego warstwy aplikacyjnej i kanałów czasu rzeczywistego;
- zebranie mierników z #tab(<mierniki-celu>) i zestawienie ich z przyjętymi progami;
- przeprowadzenie testów funkcjonalnych i wydajnościowych.

== Zakres funkcjonalny
Zakres funkcjonalny obejmuje najważniejsze procesy niezbędne do działania platformy. Po stronie użytkownika przewidziano rejestrację, logowanie i uwierzytelnianie oraz autoryzację zależną od roli. System ma umożliwiać rozpoczęcie i zakończenie transmisji na żywo, jej odtwarzanie przez odbiorców oraz komunikację tekstową w czacie transmisji.

Uzupełnieniem są reakcje i zdarzenia w czasie rzeczywistym, informacje o nowych transmisjach i aktywności serwisu, zapis materiałów oraz ich późniejsze udostępnianie jako VOD. Zakres obejmuje także zarządzanie zasobami użytkownika: awatarem i miniaturą transmisji.

== Granice zakresu
Obraz transmisji na żywo przyjmuje i dystrybuuje do widzów usługa zarządzana. Własny serwer strumieniowania i własna sieć dostarczania treści nie wchodzą do zakresu. Aplikacja realizuje logikę konta, autoryzację, czat, powiadomienia i zarządzanie metadanymi transmisji oraz nagrań. Warstwa kliencka i serwerowa pozostaje przy technologiach webowych. Wybór usługi obrazu wynika z przeglądu i limitów dostawcy; uzasadnienie podano w rozdziale projektowym.

Przyjęty profil obciążenia musi mieścić się w domyślnych limitach wybranej usługi. #zgodnosc-z-limitami

== Zakres testów i walidacji
Testy obejmują dwa obszary: funkcjonalny i wydajnościowy. Testy funkcjonalne sprawdzają scenariusze użytkownika: logowanie, uruchomienie transmisji, odbiór obrazu i dźwięku, czat, reakcje oraz zapis VOD. Testy wydajnościowe oceniają czas odpowiedzi API, opóźnienie zdarzeń czasu rzeczywistego i opóźnienie obrazu, a także stabilność przy narastającym obciążeniu.

Profil docelowy testu wydajnościowego mającego wykazać skalowanie: #profil-docelowy-z-rozkladem. Obciążenie narasta etapami (#rampa-skrot-slasha, w postaci nadawcy/odbiorcy), tak aby zmiany mierników było widać na kolejnych poziomach. Sposób generowania obciążenia i pomiaru opisano w rozdziale metodyki.

== Zakres poza pracą
Poza celem pozostają GitOps, Terraform, Loki i Jenkins. GitOps utrzymuje deklarowany stan środowiska przez automatyczne pobieranie wersji z repozytorium #cite(<opengitops>). Terraform opisuje infrastrukturę jako kod, a Jenkins automatyzuje potok wydań #cite(<terraform_intro>) #cite(<jenkins_intro>). Loki zostaje przy logach. Te cztery pozycje nie rozstrzygają o spełnieniu celu. Poza zakresem zostają też budowa globalnej infrastruktury CDN (ang. _Content Delivery Network_), wdrożenie komercyjnych mechanizmów monetyzacji, przygotowanie natywnych aplikacji mobilnych oraz formalna certyfikacja bezpieczeństwa systemu.

Elementy te należy traktować jako potencjalne kierunki dalszego rozwoju rozwiązania po zakończeniu prac objętych zakresem niniejszej pracy inżynierskiej.

== Element nowatorski i wartość pracy
Wartość opracowania wynika z połączenia funkcji społecznościowych z transmisją wideo w czasie rzeczywistym w jednym systemie oraz z wykazania jego skalowania w ustalonych, sprawdzalnych granicach obciążenia. Praca pokazuje także, jak dobrać profil testu do limitów usług zarządzanych.

== Wymagania funkcjonalne
Wymagania funkcjonalne wynikają z zakresu i dotyczą obserwowalnego zachowania systemu:

- użytkownik zakłada konto, uwierzytelnia się i otrzymuje uprawnienia zgodne z rolą;
- nadawca rozpoczyna i kończy transmisję na żywo, a odbiorca odtwarza obraz i dźwięk tej transmisji;
- w trakcie transmisji działa czat, publikacja reakcji i powiadomienie o zdarzeniu serwisu;
- po zakończeniu transmisji nagranie zostaje zapisane i udostępnione jako VOD;
- użytkownik zmienia awatar oraz miniaturę transmisji.

== Wymagania niefunkcjonalne
Wymagania niefunkcjonalne określają warunki, pod którymi funkcje uznaje się za spełnione. Progi liczbowe zestawiono w #tab(<mierniki-celu>).

- opóźnienie obrazu w trybie interaktywnym nie przekracza #opoznienie-obrazu-max-s s od zdarzenia przed kamerą do obrazu u widza; próg odpowiada trybowi niskiego opóźnienia YouTube, w którym większość widzów doświadcza opóźnienia mniejszego niż #opoznienie-obrazu-max-s s #cite(<youtube_latency>);
- system utrzymuje profil docelowy #profil-skrot (nadawcy/odbiorcy) bez przekroczenia progów z tabeli;
- 95. percentyl czasu odpowiedzi API nie przekracza #czas-api-p95-max-ms ms, a 95. percentyl opóźnienia zdarzeń czatu #opoznienie-czatu-p95-max-ms ms (założenia własne);
- warstwa aplikacyjna daje się powielić na więcej niż jedną instancję bez przywiązania odbiorcy do jednego węzła;
- ponowione żądanie zapisu z tym samym kluczem daje jeden skutek;
- przerwa jednej instancji aplikacji nie przerywa już przyjętej transmisji;
- mierniki z tabeli można odczytać z danych zebranych w teście.

Wartości opublikowane przez platformy służą jako punkt odniesienia dla progów. Nie są wynikiem pomiaru wykonanego w tej pracy.

== Kryteria osiągnięcia celu
Cel uznaje się za osiągnięty, gdy spełnione są wymagania funkcjonalne oraz mierniki z #tab(<mierniki-celu>) mieszczą się w progach. Kryteria wyznaczono po przeglądzie wartości stosowanych przez platformy i dostawców (#tab(<kryteria-u-innych>)): próg opóźnienia obrazu pochodzi z publikowanych wartości, pozostałe progi są założeniami własnymi autora do akceptacji promotora. W tabeli nie ma wyników pomiarów.

#tabela(
  [Mierniki i progi kryteriów celu],
  table(
    columns: (1.6fr, 1.6fr, 2fr),
    align: left,
    [Miernik], [Co rozstrzyga], [Próg],
    [Czas do pierwszej klatki], [odbiór transmisji], tabela-zalozenie-pierwsza-klatka,
    [Opóźnienie obrazu od kamery do widza], [tryb interaktywny], tabela-zalozenie-opoznienie,
    [Opóźnienie dostarczenia zdarzenia czatu], [interakcja społecznościowa], tabela-zalozenie-czat,
    [Czas odpowiedzi API], [ścieżka krytyczna żądań], tabela-zalozenie-api,
    [Odsetek nieudanych odtworzeń], [stabilność odbioru], tabela-zalozenie-odtworzenia,
    [Liczba równoległych sesji utrzymanych w teście], [skalowanie], tabela-zalozenie-sesje,
    [Skutek ponowionego żądania zapisu], [idempotentność], [jeden skutek przy tym samym kluczu],
  ),
  zrodlo: zrodlo-tabela-mierniki,
) <mierniki-celu>

Test funkcjonalny potwierdza kolejne wiersze wymagań funkcjonalnych. Test obciążenia zapisuje mierniki z tabeli na kolejnych etapach rampy. Wyników tych testów rozdział nie podaje. Wyznaczają one ramy dalszych rozdziałów, w których przedstawiono metodykę, projekt i implementację oraz weryfikację.
