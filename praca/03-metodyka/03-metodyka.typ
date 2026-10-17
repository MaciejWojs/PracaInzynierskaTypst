#import "/praca/parametry.typ": (
  profil-docelowy-krotko, profil-skrot, rampa-skrot-slasha,
  odbiorcy-na-transmisje, nadawcy-docelowi, odbiorcy-docelowi,
  opoznienie-obrazu-max-s, czas-api-p95-max-ms, opoznienie-czatu-p95-max-ms,
)

= Metodyka projektu i weryfikacji
W rozdziale uzasadniono wybór metod, technik i narzędzi przewidzianych do realizacji celu pracy. Opis ma umożliwić odtworzenie kroków projektowych, implementacyjnych i weryfikacyjnych przez inną osobę. Implementacja nie jest jeszcze ukończona, dlatego procedury pomiarowe opisano jako planowane, a szczegóły narzędzi do generowania obciążenia uzupełni się po ich wyborze.

== Metody projektowe i narzędzia implementacji
Projekt architektury opiera się na przeglądzie rozwiązań oraz na założeniach z rozdziału celu. Implementację prowadzi się iteracyjnie: najpierw ścieżka krytyczna konta i API, następnie integracja transmisji na żywo, warstwa czasu rzeczywistego oraz zadania asynchroniczne. Kod jest wersjonowany w systemie kontroli wersji. Środowisko uruchomieniowe i usługi chmurowe dobiera się zgodnie z granicami zakresu z rozdziału celu, a profil obciążenia sprawdza się względem domyślnych limitów wybranej usługi.

== Pomiar kryteriów i obserwowalność
Mierzone kryteria są takie same jak w rozdziale „Cel i zakres pracy”: opóźnienie obrazu (próg #opoznienie-obrazu-max-s s), opóźnienie zdarzeń czatu (95. percentyl, próg #opoznienie-czatu-p95-max-ms ms), 95. percentyl czasu odpowiedzi API (próg #czas-api-p95-max-ms ms), czas do pierwszej klatki, odsetek nieudanych odtworzeń, skutek ponowienia żądania zapisu oraz liczba równoległych sesji w teście obciążenia.

Mierniki zbiera się z szeregów czasowych udostępnianych przez aplikację i pobieranych przez Prometheus. Wizualizację przygotowuje się w Grafanie #cite(<prometheus_overview>) #cite(<grafana_intro>). Pomiar opóźnienia obrazu i czasu do pierwszej klatki wymaga znaczników czasu po stronie nadawcy i widza, powiązanych ze zdarzeniami w aplikacji. Opóźnienie czatu mierzy się jako różnicę czasu między wysłaniem wiadomości na jednym kliencie a jej wyświetleniem na drugim w tej samej transmisji. Sposób wstrzykiwania znaczników czasu do strumienia ustali się po wyborze narzędzi klienckich.

== Scenariusze testów funkcjonalnych i obciążeniowych
Testy funkcjonalne obejmują scenariusze użytkownika wymienione w zakresie testów rozdziału celu: logowanie, start i koniec transmisji, odbiór obrazu i dźwięku, czat, reakcje, powiadomienia oraz zapis VOD. Każdy scenariusz wykonuje się w tej samej kolejności kroków, aby wynik dało się powtórzyć.

Testy obciążeniowe mają potwierdzić skalowanie przy profilu docelowym z rozdziału celu: #profil-docelowy-krotko. W jednym przebiegu stosuje się rampę etapową (#rampa-skrot-slasha: nadawcy/odbiorcy), aby zestawić mierniki na kolejnych poziomach obciążenia. Odbiorców rozdziela się równomiernie między aktywne transmisje, czyli około #odbiorcy-na-transmisje odbiorców na jedną transmisję.

Profil #profil-skrot ma być osiągalny w środowisku testowym bez ręcznej obsługi. W tym celu planuje się dwie klasy generatorów. Nadawców symulują procesy, które wysyłają do usługi obrazu strumień z gotowego, wcześniej zakodowanego pliku (kopiowanie strumienia bez ponownego kodowania ogranicza obciążenie procesora generatora). Odbiorców symulują klienci odtwarzający adresy wyjściowe oraz utrzymujący połączenia WebSocket i SSE do aplikacji. Wybór konkretnych narzędzi i sposób rozłożenia generatorów na maszyny ustali się po próbnych przebiegach.

Liczbę replik usługi aplikacyjnej, parametry Redis lub Valkey oraz limity ALB dobiera się przed testem na podstawie próbnych przebiegów. Ingest i dystrybucję obrazu pozostawia się usłudze zarządzanej, aby obciążenie warstwy własnej nie obejmowało kodowania. Przed testem porównuje się domyślne limity z wartościami z konsoli Service Quotas konta i regionu docelowego. Jeśli któryś limit okaże się niższy niż w dokumentacji, najpierw zmniejsza się profil w pliku parametrów, a dopiero potem składa wniosek o zwiększenie limitu. Jeżeli któryś etap rampy nie osiągnie założonej liczby sesji (#nadawcy-docelowi nadawców, #odbiorcy-docelowi odbiorców na profilu docelowym), rejestruje się maksymalny osiągnięty poziom i przyczynę (limit zasobów, limit połączeń, błąd generatora), bez zawyżania wyniku.

Przed uruchomieniem testu rejestruje się wersję oprogramowania, konfigurację usług i parametry generatora, aby zestawienie wyników w rozdziale projektowym było odtwarzalne.
