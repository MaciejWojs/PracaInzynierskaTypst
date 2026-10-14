#import "/szablon/template.typ": tabela, tab

= Cel i zakres pracy
Na podstawie analizy rozwiązań rynkowych oraz technologii wykorzystywanych we współczesnych platformach streamingowych określono cel pracy i zakres działań projektowo-implementacyjnych. W rozdziale doprecyzowano, jakie elementy systemu zostaną zrealizowane, jakie ograniczenia przyjęto oraz według jakich kryteriów będzie oceniany końcowy rezultat.

== Cel pracy
Celem pracy jest zaprojektowanie i zaimplementowanie społecznościowej platformy wideo oraz wykazanie, że działa. Platforma ma umożliwić transmisję na żywo, odbiór obrazu i dźwięku, czat, reakcje, powiadomienia i zapis nagrania. Do celu należy też zebranie mierników z #tab(<mierniki-celu>). Usługa wystawia metryki, Prometheus je pobiera, a Grafana składa z nich panele testu #cite(<prometheus_overview>) #cite(<grafana_intro>).

W ujęciu technicznym realizacja celu obejmuje:
- przygotowanie mechanizmu publikacji i odtwarzania transmisji na żywo;
- zapewnienie funkcji społecznościowych, takich jak czat, reakcje i powiadomienia;
- wdrożenie procesu zapisu transmisji oraz późniejszego udostępniania nagrań;
- zaprojektowanie architektury umożliwiającej skalowanie poziome;
- zebranie mierników czasu odpowiedzi, opóźnienia zdarzeń, liczby sesji i odsetka błędów;
- przeprowadzenie testów funkcjonalnych i wydajnościowych potwierdzających spełnienie przyjętych założeń.

== Zakres funkcjonalny
Zakres funkcjonalny pracy obejmuje implementację najważniejszych procesów biznesowych, które są niezbędne do działania platformy. Po stronie użytkownika przewidziano obsługę rejestracji, logowania i uwierzytelniania, a także mechanizmy autoryzacji zależne od przypisanej roli. System ma również umożliwiać rozpoczęcie i zakończenie transmisji na żywo, jej odtwarzanie przez odbiorców oraz prowadzenie komunikacji tekstowej w ramach czatu transmisji.

Uzupełnieniem podstawowych funkcji będą mechanizmy publikowania reakcji i zdarzeń w czasie rzeczywistym, prezentowania informacji o nowych transmisjach i aktywności serwisu, a także obsługa zapisu materiałów i ich późniejszego udostępniania w formie VOD (ang. _Video on Demand_). Zakres pracy obejmuje również zarządzanie wybranymi zasobami multimedialnymi użytkownika, w szczególności awatarem oraz miniaturą transmisji.

== Zakres architektury i integracji
Układ rozdziela aplikację od ścieżki obrazu. Warstwa frontendowa obsługuje publikowanie transmisji, odbiór i interakcje społecznościowe. Warstwa backendowa zostaje przy logice konta, autoryzacji, API (ang. _Application Programming Interface_) i czacie. Przyjęcie sygnału na żywo, transkodowanie i dystrybucja do widza przechodzą do usług zarządzanych AWS wskazanych w przeglądzie: MediaLive albo IVS dla transmisji na żywo oraz MediaConvert dla nagrania. Pliki pozostają w S3. Zadania poboczne, takie jak miniatury i domknięcie nagrania, idą kolejką. Czat i powiadomienia zostają osobnym kanałem, opartym na WebSocket i SSE (ang. _Server-Sent Events_), niezależnie od protokołu obrazu. Podejście DDD (ang. _Domain-Driven Design_) oraz kontrakty DTO (ang. _Data Transfer Object_) dotyczą warstwy aplikacyjnej, nie kodowania wideo.

=== Wejście żądania
Krótkie żądania przyjmuje Amazon API Gateway w postaci REST API. Do tego zasobu dopina się AWS WAF (ang. _Web Application Firewall_) #cite(<aws_waf>). TLS (ang. _Transport Layer Security_) kończy brama. Autoryzator bramy sprawdza podpis tokenu JWT (ang. _JSON Web Token_). Podpis powstaje w usłudze aplikacyjnej przy logowaniu. Token jedzie w nagłówku `Authorization`, poza szyfrogramem treści. Dalej brama przekazuje żądanie do usługi aplikacyjnej protokołem HTTP.

Połączenia WebSocket i SSE przyjmuje ALB (ang. _Application Load Balancer_). TLS kończy równoważnik, a WAF jest przypięty do tego samego zasobu #cite(<aws_waf>). WAF monitoruje żądania przekazywane do chronionego zasobu i sam połączenia nie kończy. Dokumentacja wiąże go między innymi z REST API w API Gateway oraz z ALB. HTTP API na tej liście nie występuje, dlatego krótkie żądania wchodzą przez REST API.

Otwartą odpowiedź SSE utrzymuje ALB. W HTTP API czas integracji wynosi 30 s i nie podlega zwiększeniu #cite(<aws_http_api_quotas>).

=== Sesja kryptograficzna treści
Oprócz TLS treść krótkich żądań jest szyfrowana na odcinku klient–platforma. Uzgodnienie klucza sesji opiera się na wymianie kluczy publicznych ECDH (ang. _Elliptic Curve Diffie–Hellman_). Z uzgodnienia powstaje klucz symetryczny sesji. Klucz prywatny długoterminowy serwera jest wspólny dla replik. Klucz sesji, z krótkim czasem życia, trafia do Redis pod identyfikatorem sesji, więc żądanie może obsłużyć dowolna replika #cite(<redis_docs>).

Ciało POST i JSON odpowiedzi GET są szyfrogramem tego klucza. Odszyfrowanie ciała i zaszyfrowanie odpowiedzi wykonuje pierwsza warstwa usługi aplikacyjnej. Brama API tego kroku nie wykonuje. Nagłówki `Authorization`, klucz idempotencji i `traceparent` zostają jawne #cite(<ietf_idempotency>) #cite(<w3c_trace_context>). Korzystają z nich weryfikacja tokenu i powiązanie wpisów jednej operacji.

Szyfrowanie dotyczy odcinka klient–platforma. Czat na serwerze jest jawny, bo ta sama treść idzie do pozostałych odbiorców transmisji. Reguły WAF widzą nagłówki, rozmiar i częstość żądań. Ciało jest szyfrogramem, więc ocena treści JSON na tej ścieżce nie ma pola źródłowego. Krzywa, format ramki i rotacja klucza zostaną ustalone przy implementacji.

=== Usługa aplikacyjna, dane i zadania
Przyjęto jedną usługę aplikacyjną w co najmniej dwóch replikach. Obejmuje konto, podpis JWT, sesję kryptograficzną, metadane transmisji, wejście czatu i zlecenie kodowania. Odczyt danych trwałych idzie przez repozytorium. Repozytorium najpierw sprawdza pamięć podręczną. Przy braku wpisu albo jego nieaktualności zapytanie idzie do bazy, a wynik wraca do pamięci podręcznej. Klucz sesji i zdarzenia między replikami korzystają z Redis albo z Valkey #cite(<valkey_docs>).

Zmiana awatara i miniatury schodzi ze ścieżki krytycznej żądania. Usługa odkłada zadanie do kolejki SQS (ang. _Simple Queue Service_) albo do dotychczasowego brokera #cite(<aws_sqs>). Proces roboczy przekształca plik, zapisuje go w S3 i aktualizuje metadane. Workery stoją poza bramą. Powtórzenie zapisu z tym samym kluczem idempotencji daje jeden skutek. Repliki czatu nie wołają się po HTTP. Zdarzenie idzie przez publikację i subskrypcję.

=== Ścieżka obrazu
Usługa aplikacyjna wydaje klucz transmisji i adres odtwarzania. Ingest i drabina jakości są w usłudze zarządzanej. Wybór między MediaLive a IVS zostaje otwarty, jak w zestawieniu dostawców. Nagranie kończy w S3. Profil VOD, gdy jest potrzebny, zleca MediaConvert. Sterowanie tymi usługami jest po stronie usługi aplikacyjnej. Brama API transkodowania nie wywołuje. Nadawca wysyła obraz do ingestu, a widz odbiera go z adresu odtwarzania. Przerwa repliki API nie zrywa już przyjętego strumienia.

=== Skalowanie WebSocket
Połączenie zostaje na replice, która przyjęła podniesienie HTTP/1.1 #cite(<aws_alb_listeners>). Nowe połączenia rozkłada ALB. Wiadomość czatu wpada na jedną replikę. Do klientów na pozostałych replikach idzie przez publikację i subskrypcję w Redis, na kanale danej transmisji. Po ponownym połączeniu odbiorca może trafić na inną replikę i dalej dostaje zdarzenia tego kanału.

RFC 8441 opisuje uruchomienie WebSocket jako strumienia jednego połączenia HTTP/2 #cite(<rfc8441>). Multipleksowanie zbija kilka gniazd jednego klienta w jedno połączenie TCP. Rozdział ruchu między repliki robi publikacja z subskrypcją. Na ALB WebSocket powstaje przez podniesienie połączenia HTTP/1.1, a HTTP/2 na nasłuchu HTTPS służy równoległym żądaniom #cite(<aws_alb_listeners>). Czat i powiadomienia obsługują te same repliki i ten sam mechanizm publikacji z subskrypcją.

=== Skalowanie powiadomień SSE
SSE jest długą odpowiedzią HTTP. Powiadomienia idą przez ten sam ALB co WebSocket. Limit bezczynności równoważnika ustawia się powyżej odstępu między komentarzami wysyłanymi przez usługę, żeby połączenie zostało uznane za żywe.

HTTP/2 na nasłuchu HTTPS ALB niesie jednym połączeniem do 128 żądań równolegle #cite(<aws_alb_listeners>). Z tego korzystają strumienie SSE. Jeden zalogowany użytkownik utrzymuje jedno połączenie SSE dla powiadomień serwisu. Czat transmisji zostaje na WebSocket. Skala pozioma jest ta sama co przy czacie: część połączeń na replikę, rozesłanie przez publikację i subskrypcję.

=== Obserwowalność mierników
Każda replika wystawia punkt końcowy metryk. Prometheus pobiera z niego szeregi czasowe #cite(<prometheus_overview>). Grafana składa panele czasu odpowiedzi, opóźnienia zdarzeń, liczby sesji i odsetka błędów #cite(<grafana_intro>). Te szeregi zasilają test obciążenia. Loki, który indeksuje logi, do tego celu nie wchodzi #cite(<loki_overview>).

== Zakres technologiczny
Warstwa kliencka i serwerowa aplikacji pozostaje przy technologiach webowych. Transmisja na żywo korzysta z usługi zarządzanej AWS, MediaLive albo IVS, a nagranie z MediaConvert. Pliki binarne trafiają do S3. Czat idzie przez WebSocket, powiadomienia przez SSE, oba przez ALB z WAF. Krótkie żądania wchodzą przez REST API w API Gateway, z weryfikacją JWT i z WAF na tej bramie. Stan ulotny, klucz sesji kryptograficznej i propagacja zdarzeń między replikami zostają w Redis albo Valkey. Zadania asynchroniczne idą kolejką. Mierniki zbiera Prometheus, a panele składa Grafana. Własny serwer strumieniowania i własna sieć dostarczania treści nie wchodzą do zakresu.

== Zakres testów i walidacji
W celu potwierdzenia poprawności działania systemu przewidziano realizację testów w dwóch głównych obszarach: funkcjonalnym oraz wydajnościowym. Testy funkcjonalne posłużą do weryfikacji poprawności scenariuszy użytkownika i oceny, czy najważniejsze funkcje platformy działają zgodnie z założeniami. Z kolei testy wydajnościowe pozwolą ocenić zachowanie systemu przy rosnącym obciążeniu oraz wskazać potencjalne ograniczenia projektowe.

W zakresie testów funkcjonalnych uwzględnione zostaną między innymi proces logowania, uruchamianie transmisji, odbiór obrazu i dźwięku, działanie czatu, publikacja reakcji oraz zapis materiału VOD. Testy wydajnościowe obejmą analizę czasu odpowiedzi API, opóźnień dostarczania zdarzeń czasu rzeczywistego oraz stabilności przy zwiększonej liczbie użytkowników. Szeregi tych mierników pobiera Prometheus, a Grafana pokazuje je w panelach testu obciążenia.

== Zakres poza pracą
Poza celem pozostają GitOps, Terraform, Loki i Jenkins. GitOps utrzymuje deklarowany stan środowiska przez automatyczne pobieranie wersji z repozytorium #cite(<opengitops>). Terraform opisuje infrastrukturę jako kod, a Jenkins automatyzuje potok wydań #cite(<terraform_intro>) #cite(<jenkins_intro>). Loki zostaje przy logach. Te cztery pozycje nie rozstrzygają o spełnieniu celu. Poza zakresem zostają też budowa globalnej infrastruktury CDN (ang. _Content Delivery Network_), wdrożenie komercyjnych mechanizmów monetyzacji, przygotowanie natywnych aplikacji mobilnych oraz formalna certyfikacja bezpieczeństwa systemu.

Elementy te należy traktować jako potencjalne kierunki dalszego rozwoju rozwiązania po zakończeniu prac objętych zakresem niniejszej pracy inżynierskiej.

== Element nowatorski i wartość pracy
Wartość opracowania wynika przede wszystkim z połączenia wielu technologii w ramach jednego, spójnego systemu. Nowatorski charakter rozwiązania polega na integracji funkcji społecznościowych z transmisją wideo w czasie rzeczywistym, a także na powiązaniu tej warstwy z architekturą przygotowaną do skalowania i z mechanizmami asynchronicznego przetwarzania danych multimedialnych.

Z punktu widzenia inżynierskiego istotne znaczenie ma również zestawienie warstwy czasu rzeczywistego z mechanizmami przechowywania danych ulotnych i kolejkowania zadań. Takie podejście pozwala ograniczyć opóźnienia odczuwane przez użytkownika, a jednocześnie sprzyja utrzymaniu stabilności działania całego systemu.

== Wymagania funkcjonalne
Wymagania funkcjonalne wynikają z zakresu opisanego powyżej i dotyczą obserwowalnego zachowania systemu:

- użytkownik zakłada konto, uwierzytelnia się i otrzymuje uprawnienia zgodne z rolą;
- nadawca rozpoczyna i kończy transmisję na żywo, a odbiorca odtwarza obraz i dźwięk tej transmisji;
- w trakcie transmisji działa czat, publikacja reakcji i powiadomienie o zdarzeniu serwisu;
- po zakończeniu transmisji nagranie zostaje zapisane i udostępnione jako VOD;
- użytkownik zmienia awatar oraz miniaturę transmisji.

== Wymagania niefunkcjonalne
Wymagania niefunkcjonalne określają warunki, pod którymi funkcje z poprzedniego podrozdziału uznaje się za spełnione:

- opóźnienie obrazu w trybie interaktywnym ma mieścić się w paśmie, które publiczne platformy opisują jako niskie; jako założenie projektowe przyjmuje się próg 10 s od zdarzenia przed kamerą do obrazu u widza, zgodny z trybem niskiego opóźnienia YouTube, w którym większość widzów doświadcza opóźnienia mniejszego niż 10 s #cite(<youtube_latency>);
- warstwa aplikacyjna i warstwa zdarzeń mają dać się powielić na więcej niż jedną instancję bez przywiązania odbiorcy czatu do jednego węzła;
- przetworzenie nagrania i obrazu użytkownika odbywa się poza ścieżką krytyczną żądania HTTP, przez kolejkę zadań;
- ponowienie tego samego żądania zapisu nie tworzy drugiego skutku; żądanie niesie identyfikator pozwalający połączyć wpisy dziennika jednej operacji;
- przerwa jednej instancji aplikacji nie przerywa przyjętego już strumienia w warstwie multimedialnej;
- mierniki z tabeli celu da się odczytać z szeregów zebranych przez Prometheus i pokazanych w Grafanie.

Progi z dokumentacji YouTube i z opisu HLS o niskim opóźnieniu są punktem odniesienia dla założeń. Nie są wynikiem pomiaru wykonanego w tej pracy.

== Kryteria osiągnięcia celu
Spełnienie celu stwierdza się przez sprawdzenie wymagań funkcjonalnych oraz przez zapis mierników z #tab(<mierniki-celu>). Wartości progowe, których nie podano w dokumentacji jako wymagania tej pracy, pozostają puste do czasu badań. W tabeli nie ma wyników.

#tabela(
  [Mierniki przypisane do kryteriów celu],
  table(
    columns: (1.6fr, 1.8fr, 1.6fr),
    align: left,
    [Miernik], [Co rozstrzyga], [Założenie],
    [Czas do pierwszej klatki], [odbiór transmisji], [do wyznaczenia w badaniu],
    [Opóźnienie obrazu od kamery do widza], [tryb interaktywny], [nie więcej niż 10 s],
    [Opóźnienie dostarczenia zdarzenia czatu], [interakcja społecznościowa], [do wyznaczenia w badaniu],
    [Percentyl 95. czasu odpowiedzi API], [ścieżka krytyczna żądań], [do wyznaczenia w badaniu],
    [Odsetek nieudanych odtworzeń], [stabilność odbioru], [do wyznaczenia w badaniu],
    [Liczba równoległych sesji utrzymanych w teście], [skalowanie], [co najmniej dwa profile obciążenia],
    [Skutek ponowionego żądania zapisu], [idempotentność], [jeden skutek przy tym samym kluczu],
  ),
  zrodlo: [opracowanie własne; próg 10 s jako założenie na podstawie opisu trybu niskiego opóźnienia YouTube],
) <mierniki-celu>

Test funkcjonalny potwierdza kolejne wiersze wymagań funkcjonalnych. Test obciążenia zapisuje mierniki opóźnienia, czasu odpowiedzi i liczby sesji zebrane przez Prometheus i pokazane w Grafanie. Wyników tych testów ten rozdział nie podaje. Tak określony cel i zakres wyznaczają ramy dalszych rozdziałów, w których przedstawione zostaną metodyka, implementacja oraz rezultaty badań.
