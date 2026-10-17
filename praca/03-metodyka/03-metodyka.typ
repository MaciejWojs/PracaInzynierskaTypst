= Metodyka projektu i weryfikacji
W rozdziale uzasadniono wybór metod, technik i narzędzi użytych do realizacji celu pracy. Opis ma umożliwić odtworzenie kroków projektowych, implementacyjnych i weryfikacyjnych przez inną osobę.

== Metody projektowe i narzędzia implementacji
Projekt architektury oparto na analizie rozwiązań z rozdziału przeglądu oraz na założeniach z rozdziału celu. Implementację prowadzono iteracyjnie: najpierw ścieżka krytyczna konta i API, następnie integracja transmisji na żywo, warstwa czasu rzeczywistego oraz zadania asynchroniczne. Do wersjonowania kodu wykorzystano system kontroli wersji. Środowisko uruchomieniowe i usługi chmurowe dobierano zgodnie z zakresem technologicznym opisanym w rozdziale celu.

== Pomiar kryteriów i obserwowalność
Kryteria oceny systemu są takie same jak w rozdziale „Cel i zakres pracy”: opóźnienie obrazu, opóźnienie zdarzeń czatu, percentyl 95. czasu odpowiedzi API, odsetek nieudanych odtworzeń, skutek ponowienia żądania zapisu oraz liczba równoległych sesji w teście obciążenia. Mierniki zbierano ze szeregów czasowych udostępnianych przez aplikację i pobieranych przez Prometheus; wizualizację przygotowano w Grafanie #cite(<prometheus_overview>) #cite(<grafana_intro>). Pomiar opóźnienia obrazu i czasu do pierwszej klatki powiązano ze zdarzeniami w aplikacji i z logami warstwy odtwarzania. Opóźnienie czatu mierzono jako różnicę czasu między wysłaniem wiadomości na jednym kliencie a jej wyświetleniem na drugim w tej samej transmisji.

== Scenariusze testów funkcjonalnych i obciążeniowych
Testy funkcjonalne obejmują scenariusze użytkownika wymienione w zakresie testów rozdziału celu: logowanie, start i koniec transmisji, odbiór obrazu i dźwięku, czat, reakcje, powiadomienia oraz zapis VOD. Każdy scenariusz wykonuje się według tej samej kolejności kroków, aby wynik dało się powtórzyć.

Testy obciążeniowe wykonuje się przy założeniu projektowym, uzgodnionym z promotorem: co najmniej trzech jednoczesnych nadawców prowadzących transmisję na żywo oraz co najmniej trzydziestu jednoczesnych odbiorców łącznie, rozłożonych na te transmisje. Drugi profil obciążenia podnosi liczbę odbiorców przy tej samej liczbie nadawców, zgodnie z wierszem tabeli mierników o dwóch profilach obciążenia. Generatory ruchu symulują żądania API, połączenia WebSocket, SSE oraz odtwarzanie strumieni. Przed uruchomieniem testu rejestruje się wersję oprogramowania, konfigurację usług i parametry generatora, aby zestawienie wyników w rozdziale projektowym było odtwarzalne.
