#import "/praca/parametry.typ": (
  profil-docelowy-krotko, profil-skrot, rampa-skrot-slasha,
  odbiorcy-na-transmisje, nadawcy-docelowi, odbiorcy-docelowi,
)

= Metodyka projektu i weryfikacji
W rozdziale uzasadniono wybór metod, technik i narzędzi użytych do realizacji celu pracy. Opis ma umożliwić odtworzenie kroków projektowych, implementacyjnych i weryfikacyjnych przez inną osobę.

== Metody projektowe i narzędzia implementacji
Projekt architektury oparto na analizie rozwiązań z rozdziału przeglądu oraz na założeniach z rozdziału celu. Implementację prowadzono iteracyjnie: najpierw ścieżka krytyczna konta i API, następnie integracja transmisji na żywo, warstwa czasu rzeczywistego oraz zadania asynchroniczne. Do wersjonowania kodu wykorzystano system kontroli wersji. Środowisko uruchomieniowe i usługi chmurowe dobierano zgodnie z zakresem technologicznym opisanym w rozdziale celu.

== Pomiar kryteriów i obserwowalność
Kryteria oceny systemu są takie same jak w rozdziale „Cel i zakres pracy”: opóźnienie obrazu, opóźnienie zdarzeń czatu, percentyl 95. czasu odpowiedzi API, odsetek nieudanych odtworzeń, skutek ponowienia żądania zapisu oraz liczba równoległych sesji w teście obciążenia. Mierniki zbierano ze szeregów czasowych udostępnianych przez aplikację i pobieranych przez Prometheus; wizualizację przygotowano w Grafanie #cite(<prometheus_overview>) #cite(<grafana_intro>). Pomiar opóźnienia obrazu i czasu do pierwszej klatki powiązano ze zdarzeniami w aplikacji i z logami warstwy odtwarzania. Opóźnienie czatu mierzono jako różnicę czasu między wysłaniem wiadomości na jednym kliencie a jej wyświetleniem na drugim w tej samej transmisji.

== Scenariusze testów funkcjonalnych i obciążeniowych
Testy funkcjonalne obejmują scenariusze użytkownika wymienione w zakresie testów rozdziału celu: logowanie, start i koniec transmisji, odbiór obrazu i dźwięku, czat, reakcje, powiadomienia oraz zapis VOD. Każdy scenariusz wykonuje się według tej samej kolejności kroków, aby wynik dało się powtórzyć.

Testy obciążeniowe mają potwierdzić skalowanie przy profilu docelowym z rozdziału celu: #profil-docelowy-krotko. W jednym przebiegu stosuje się rampę etapową (#rampa-skrot-slasha: nadawcy/odbiorcy), aby zestawić mierniki na kolejnych poziomach obciążenia. Odbiorców rozdziela się równomiernie między aktywne transmisje, zgodnie z założeniem około #odbiorcy-na-transmisje widzów na stream.

Żeby profil #profil-skrot był osiągalny w środowisku testowym, stosuje się symulację klientów (żądania HTTP, WebSocket, SSE oraz odtwarzanie adresów wyjściowych z warstwy multimedialnej) zamiast wyłącznie ręcznej obsługi interfejsu. Liczbę replik usługi aplikacyjnej, parametry Redis lub Valkey oraz limity ALB dobiera się przed testem na podstawie próbnych przebiegów; ingest i dystrybucję obrazu pozostawia się usługom AWS z zakresu pracy, aby obciążenie CPU warstwy własnej nie szło w transkodowanie. Jeżeli któryś etap rampy nie osiągnie założonej liczby sesji (#nadawcy-docelowi nadawców, #odbiorcy-docelowi odbiorców na profilu docelowym), rejestruje się maksymalny osiągnięty poziom i przyczynę (limit zasobów, limit połączeń, błąd generatora), bez zawyżania wyniku.

Przed uruchomieniem testu rejestruje się wersję oprogramowania, konfigurację usług i parametry generatora, aby zestawienie wyników w rozdziale projektowym było odtwarzalne.
