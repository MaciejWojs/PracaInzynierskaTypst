#import "/szablon/template.typ": tab
#import "/praca/parametry.typ": (
  profil-docelowy-krotko, profil-skrot, limit-ivs-strumieni, limit-ivs-widokow, limit-medialive-kanalow,
)

= Projekt, implementacja i weryfikacja
Rozdział przedstawia, w jaki sposób realizuje się cel i zakres z rozdziału „Cel i zakres pracy”: architekturę systemu, implementację z wkładem własnym autora oraz zestawienie wyników z przyjętymi kryteriami. Podrozdział o architekturze opisuje przyjęte rozwiązania projektowe. Część implementacyjna i wyniki weryfikacji zostaną uzupełnione po zakończeniu implementacji.

== Architektura systemu
Architektura rozdziela aplikację od ścieżki obrazu. Warstwa frontendowa obsługuje publikowanie transmisji, odbiór i interakcje społecznościowe. Warstwa backendowa odpowiada za logikę konta, autoryzację, API (ang. _Application Programming Interface_) i czat. Przyjęcie sygnału na żywo, kodowanie i dystrybucję do widza przejmuje usługa zarządzana AWS, a nagranie obsługuje MediaConvert. Pliki przechowuje S3. Zadania poboczne, takie jak miniatury i domknięcie nagrania, odkłada się do kolejki. Czat i powiadomienia tworzą osobny kanał, oparty na WebSocket i SSE (ang. _Server-Sent Events_), niezależny od protokołu obrazu. Podejście DDD (ang. _Domain-Driven Design_) oraz kontrakty DTO (ang. _Data Transfer Object_) dotyczą warstwy aplikacyjnej, nie kodowania wideo.

=== Wejście żądania
Krótkie żądania przyjmuje Amazon API Gateway w postaci REST API. Do tego zasobu dopina się AWS WAF (ang. _Web Application Firewall_) #cite(<aws_waf>). TLS (ang. _Transport Layer Security_) kończy brama. Autoryzator bramy sprawdza podpis tokenu JWT (ang. _JSON Web Token_), który powstaje w usłudze aplikacyjnej przy logowaniu. Token jedzie w nagłówku `Authorization`, poza szyfrogramem treści. Dalej brama przekazuje żądanie do usługi aplikacyjnej protokołem HTTP.

Połączenia WebSocket i SSE przyjmuje ALB (ang. _Application Load Balancer_). TLS kończy równoważnik, a WAF jest przypięty do tego samego zasobu #cite(<aws_waf>). WAF monitoruje żądania przekazywane do chronionego zasobu i sam połączeń nie kończy. Dokumentacja wiąże go między innymi z REST API w API Gateway oraz z ALB. HTTP API na tej liście nie występuje, dlatego krótkie żądania wchodzą przez REST API.

Otwartą odpowiedź SSE utrzymuje ALB, a nie brama API. W HTTP API czas integracji wynosi 30 s i nie podlega zwiększeniu #cite(<aws_http_api_quotas>), co wyklucza prowadzenie długich połączeń przez ten typ bramy.

=== Sesja kryptograficzna treści
Oprócz TLS projekt przewiduje szyfrowanie treści krótkich żądań na odcinku klient–platforma. Uzgodnienie klucza sesji opiera się na wymianie kluczy publicznych ECDH (ang. _Elliptic Curve Diffie–Hellman_), z której powstaje klucz symetryczny sesji. Klucz prywatny długoterminowy serwera jest wspólny dla replik. Klucz sesji, z krótkim czasem życia, trafia do Redis pod identyfikatorem sesji, więc żądanie może obsłużyć dowolna replika #cite(<redis_docs>).

Ciało POST i JSON odpowiedzi GET są szyfrogramem tego klucza. Odszyfrowanie ciała i zaszyfrowanie odpowiedzi wykonuje pierwsza warstwa usługi aplikacyjnej. Brama API tego kroku nie wykonuje. Nagłówki `Authorization`, klucz idempotencji i `traceparent` pozostają jawne #cite(<ietf_idempotency>) #cite(<w3c_trace_context>), bo korzystają z nich weryfikacja tokenu i powiązanie wpisów jednej operacji.

Szyfrowanie dotyczy odcinka klient–platforma. Czat na serwerze jest jawny, ponieważ ta sama treść idzie do pozostałych odbiorców transmisji. Reguły WAF widzą nagłówki, rozmiar i częstość żądań. Ciało jest szyfrogramem, więc ocena treści JSON na tej ścieżce nie jest możliwa. Krzywa, format ramki i rotacja klucza zostaną ustalone przy implementacji.

=== Usługa aplikacyjna, dane i zadania
Przyjęto jedną usługę aplikacyjną w co najmniej dwóch replikach. Obejmuje ona konto, podpis JWT, sesję kryptograficzną, metadane transmisji, wejście czatu i zlecenie kodowania. Odczyt danych trwałych idzie przez repozytorium, które najpierw sprawdza pamięć podręczną. Przy braku wpisu albo jego nieaktualności zapytanie trafia do bazy, a wynik wraca do pamięci podręcznej. Klucz sesji i zdarzenia między replikami obsługuje Redis albo Valkey #cite(<valkey_docs>).

Zmianę awatara i miniatury wyprowadza się ze ścieżki krytycznej żądania. Usługa odkłada zadanie do kolejki SQS (ang. _Simple Queue Service_) albo do wcześniej opisanego brokera #cite(<aws_sqs>). Proces roboczy przekształca plik, zapisuje go w S3 i aktualizuje metadane. Workery pozostają poza bramą. Powtórzenie zapisu z tym samym kluczem idempotencji daje jeden skutek. Repliki czatu nie wołają się po HTTP, tylko wymieniają zdarzenia przez publikację i subskrypcję.

=== Ścieżka obrazu
Usługa aplikacyjna wydaje klucz transmisji i adres odtwarzania. Przyjęcie sygnału (ingest) i przygotowanie obrazu dla widza pozostaje po stronie usługi zarządzanej. Do testów skalowania wybrano Amazon IVS. Uzasadnienie wynika z #tab(<ivs-medialive>): domyślne limity IVS wynoszą #limit-ivs-strumieni jednoczesnych strumieni i #limit-ivs-widokow jednoczesnych widoków #cite(<aws_ivs_quotas>), co mieści profil #profil-skrot (nadawcy/odbiorcy) z zapasem. Domyślny limit MediaLive to #limit-medialive-kanalow kanałów na region #cite(<aws_medialive_quotas>), więc taki profil wymagałby wniosku o zwiększenie limitu. MediaLive pozostaje wariantem dla bardziej rozbudowanej ścieżki kodowania.

Nagranie powstaje po stronie usługi obrazu i trafia do S3. Profil VOD, gdy jest potrzebny, zleca MediaConvert. Sterowanie tymi usługami wykonuje usługa aplikacyjna, a brama API transkodowania nie wywołuje. Nadawca wysyła obraz do ingestu, a widz odbiera go z adresu odtwarzania. Przerwa repliki API nie zrywa już przyjętego strumienia, bo strumień nie przechodzi przez warstwę aplikacyjną.

=== Skalowanie WebSocket
Połączenie WebSocket zostaje na replice, która przyjęła podniesienie HTTP/1.1 #cite(<aws_alb_listeners>). Nowe połączenia rozkłada ALB. Wiadomość czatu trafia na jedną replikę, a do klientów na pozostałych replikach idzie przez publikację i subskrypcję w Redis, na kanale danej transmisji. Po ponownym połączeniu odbiorca może trafić na inną replikę i dalej otrzymuje zdarzenia tego kanału.

RFC 8441 opisuje uruchomienie WebSocket jako strumienia jednego połączenia HTTP/2 #cite(<rfc8441>). Multipleksowanie zbija kilka gniazd jednego klienta w jedno połączenie TCP. Rozdział ruchu między repliki realizuje publikacja z subskrypcją. Na ALB WebSocket powstaje przez podniesienie połączenia HTTP/1.1, a HTTP/2 na nasłuchu HTTPS służy równoległym żądaniom #cite(<aws_alb_listeners>). Czat i powiadomienia obsługują te same repliki i ten sam mechanizm publikacji z subskrypcją.

=== Skalowanie powiadomień SSE
SSE jest długą odpowiedzią HTTP. Powiadomienia idą przez ten sam ALB co WebSocket. Limit bezczynności równoważnika ustawia się powyżej odstępu między komentarzami wysyłanymi przez usługę, żeby połączenie zostało uznane za żywe.

HTTP/2 na nasłuchu HTTPS ALB niesie jednym połączeniem do 128 żądań równolegle #cite(<aws_alb_listeners>), z czego korzystają strumienie SSE. Jeden zalogowany użytkownik utrzymuje jedno połączenie SSE dla powiadomień serwisu. Czat transmisji zostaje na WebSocket. Skala pozioma jest taka sama jak przy czacie: część połączeń przypada na replikę, a rozesłanie odbywa się przez publikację i subskrypcję.

=== Obserwowalność mierników
Każda replika wystawia punkt końcowy metryk. Prometheus pobiera z niego szeregi czasowe #cite(<prometheus_overview>), a Grafana składa panele czasu odpowiedzi, opóźnienia zdarzeń, liczby sesji i odsetka błędów #cite(<grafana_intro>). Te szeregi zasilają test obciążenia. Loki, który indeksuje logi, do tego celu nie wchodzi #cite(<loki_overview>).

== Implementacja
Podrozdział zostanie uzupełniony po zakończeniu implementacji. Zawrze opis zrealizowanych modułów (konto i autoryzacja, transmisja i odtwarzanie, czat i powiadomienia, zadania asynchroniczne, nagrania) wraz z jednoznacznym wskazaniem wkładu własnego autora oraz najważniejszymi fragmentami kodu i konfiguracji, do których odsyła tekst główny. Pełne zestawienia danych i listingi trafią do załączników.

== Weryfikacja względem kryteriów
Weryfikację przeprowadza się według metodyki z poprzedniego rozdziału. Wyniki testów funkcjonalnych zostaną zestawione z wymaganiami z rozdziału celu. Wyniki testów obciążeniowych zostaną zestawione z miernikami z tabeli kryteriów: opóźnienie obrazu, czas odpowiedzi API, opóźnienie zdarzeń czatu, liczba utrzymanych sesji przy profilu docelowym (#profil-docelowy-krotko; oraz na etapach rampy) oraz stabilność odtwarzania. Wartości liczbowe po zakończeniu badań uzupełnią tabele i wykresy w tym podrozdziale. Wnioski końcowe w podsumowaniu będą się odnosić do tych samych kryteriów.
