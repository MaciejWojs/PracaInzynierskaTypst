#import "/szablon/template.typ": tabela, tab

= Przegląd technologii i istniejących rozwiązań
W tym rozdziale przedstawiono analizę rozwiązań stosowanych przez platformy konkurencyjne. Punkt ciężkości położono na aspekty, które bezpośrednio wpływają na jakość transmisji, skalowalność i stabilność działania: transport wideo, komunikację czasu rzeczywistego, warstwę danych oraz mechanizmy przetwarzania asynchronicznego.

== Analiza konkurencji w obszarze transmisji wideo
Dominujące platformy rynku, takie jak YouTube Live #cite(<youtube_live_encoder>) i Twitch #cite(<twitch_broadcast_guidelines>), realizują transmisję jako połączenie dwóch ścieżek: ingest o niskim opóźnieniu oraz dystrybucja do szerokiej publiczności przez adaptacyjne protokoły HTTP (ang. _Hypertext Transfer Protocol_). W praktyce oznacza to rozdzielenie drogi nadawcy od drogi widza. Nadawca wysyła strumień do punktu wejścia platformy, a następnie materiał jest transkodowany i publikowany w wielu profilach jakości.

W przypadku odtwarzania masowego platformy konkurencyjne utrzymują segmentację opartą o HLS (ang. _HTTP Live Streaming_) #cite(<hls_apple>) lub rozwiązania równoważne, ponieważ taki model dobrze współpracuje z CDN (ang. _Content Delivery Network_) i ułatwia obsługę skoków ruchu. Jednocześnie część usług udostępnia tryby o obniżonym opóźnieniu #cite(<twitch_low_latency>), które skracają opóźnienie kosztem bardziej restrykcyjnej konfiguracji bufora.

W warstwie WebRTC (ang. _Web Real-Time Communication_) rynek stopniowo przechodzi na standaryzację ingestu i egressu przez WHIP (ang. _WebRTC-HTTP Ingestion Protocol_) #cite(<whip_rfc>) i WHEP (ang. _WebRTC-HTTP Egress Protocol_) #cite(<whep_draft>). Podejście to upraszcza sygnalizację i ogranicza liczbę niestandardowych integracji po stronie klienta, co zwiększa interoperacyjność rozwiązań.

== Analiza konkurencji w obszarze komunikacji społecznościowej
W rozwiązaniach konkurencyjnych warstwa społecznościowa jest traktowana jako system o odrębnej charakterystyce obciążenia względem samej transmisji obrazu. Czat, reakcje i zdarzenia moderacyjne realizowane są zwykle przez stałe kanały dwukierunkowe, co pozwala utrzymać subiektywnie natychmiastową odpowiedź interfejsu WebSocket #cite(<websockets_book>).

Równolegle platformy wdrażają lekkie kanały zdarzeń jednokierunkowych do globalnych komunikatów o niskiej złożoności biznesowej, takich jak informacja o starcie streamu, zmianie kategorii lub publikacji nowego materiału. W takim scenariuszu SSE (ang. _Server-Sent Events_) #cite(<sse_spec>) często bywa prostsze operacyjnie od pełnego WebSocket dla zdarzeń broadcastowych.

Wnioskiem z analizy konkurencji jest konieczność rozdzielenia dwóch klas ruchu: komunikacji konwersacyjnej i powiadomień systemowych. Taki podział redukuje presję na pojedynczy mechanizm transportowy i ułatwia skalowanie poziome.

== Analiza konkurencji w obszarze infrastruktury realtime
Konkurencyjne platformy realizują komunikację czasu rzeczywistego w układzie wielowarstwowym: warstwa brzegowa (proxy i WAF, ang. _Web Application Firewall_), warstwa sesji (serwery aplikacyjne i WebSocket), warstwa multimedialna (ingest, transkodowanie, dystrybucja) oraz warstwa asynchroniczna. Analogiczny wzorzec może zostać odwzorowany przez użycie Nginx #cite(<nginx_lb>) jako reverse proxy i mechanizmu równoważenia obciążenia oraz ModSecurity #cite(<nginx_waf>) jako WAF.

W części multimedialnej podejście konkurencji opiera się na separacji ingestu od dystrybucji i na wieloprofilowym transkodowaniu. Często stosowany jest model z równoległym wsparciem dla strumieni o niskiej latencji oraz dla protokołów adaptacyjnych. Przykładem takiej architektury jest SRS (ang. _Simple Realtime Server_) w wersji 6 #cite(<srs_v6_docs>), który łączy funkcje ingestu, transkodowania i dystrybucji, a jednocześnie wspiera protokoły WebRTC i HLS #cite(<srs_docs>).

Analizując praktyki rynkowe, za istotne uznaje się także mechanizmy typu `http_hooks`. W dużych platformach każde zdarzenie cyklu życia transmisji zasila system zdarzeniowy i metryczny, co ułatwia monitorowanie jakości usług, rozliczanie zasobów i automatyzację procesów okołotransmisyjnych.

Istotna uwaga operacyjna dotyczy warstwy ICE (ang. _Interactive Connectivity Establishment_). Konkurencyjne platformy utrzymują infrastrukturę STUN (ang. _Session Traversal Utilities for NAT_) i TURN (ang. _Traversal Using Relays around NAT_) oraz publikują kandydatów osiągalnych z sieci publicznej, aby zwiększyć skuteczność zestawiania połączeń dla użytkowników za NAT (ang. _Network Address Translation_) w środowisku WebRTC #cite(<webrtc_spec>).

== Analiza konkurencji w obszarze danych i skalowania WebSocket
W dużych systemach społecznościowych relacyjna baza danych nie obsługuje bezpośrednio pełnego ruchu czasu rzeczywistego. Dane krótkiego życia i mechanizmy synchronizacji między instancjami są delegowane do magazynów w pamięci operacyjnej. W praktyce rynkowej oznacza to wykorzystanie Redis #cite(<redis_docs>) lub rozwiązań zgodnych protokołowo, takich jak Valkey #cite(<valkey_docs>), do sesji logowania, przechowywania tokenów, liczników widzów i blokad krótkoterminowych.

Najważniejszym elementem z perspektywy czatu i reakcji jest użycie mechanizmu publikacji i subskrypcji do propagacji zdarzeń WebSocket pomiędzy instancjami aplikacji. W modelu konkurencyjnym użytkownik może być podłączony do dowolnego węzła, a mimo to otrzymuje tę samą sekwencję zdarzeń globalnych. Takie podejście ogranicza zależność od sesji przywiązanych do jednego węzła i ułatwia automatyczne skalowanie.

== Analiza konkurencji w obszarze kolejek i zadań ciężkich
Platformy o dużej skali separują operacje krytyczne czasowo od zadań obciążających procesor (CPU, ang. _Central Processing Unit_) lub operacje wejścia-wyjścia (I/O, ang. _Input/Output_). Typowym przykładem są operacje na obrazach użytkownika: walidacja pliku, generowanie kilku rozdzielczości, kompresja oraz publikacja do magazynu. Konkurencja realizuje taki przepływ przez broker wiadomości RabbitMQ #cite(<rabbitmq_docs>) i model AMQP (ang. _Advanced Message Queuing Protocol_) #cite(<amqp_model>) z procesami roboczymi konsumenckimi, co stabilizuje opóźnienia API (ang. _Application Programming Interface_).

W analizowanych rozwiązaniach rynkowych zadania asynchroniczne są realizowane przez kolejki o gwarantowanym dostarczeniu i możliwości ponawiania. Dzięki temu operacje kosztowne obliczeniowo nie obciążają ścieżki krytycznej żądań użytkownika.

== Analiza konkurencji w obszarze storage obiektowego
Konkurencja niemal powszechnie wykorzystuje obiektowe przechowywanie plików kompatybilne z API S3 #cite(<s3_api>), często implementowane także przez rozwiązania takie jak MinIO #cite(<minio_docs>). Powód jest praktyczny: duża trwałość danych, łatwa integracja z CDN i proste skalowanie niezależnie od warstwy aplikacyjnej. W tym modelu przechowuje się materiały VOD (ang. _Video on Demand_), miniatury streamów i obrazy profilowe.

W praktyce konkurencyjnej częsty jest przepływ zdarzeniowy, w którym nagranie jest najpierw zapisywane lokalnie przez warstwę multimedialną, a następnie przenoszone do storage obiektowego przez osobny proces roboczy. Takie podejście minimalizuje ryzyko utraty materiału i upraszcza dalszą dystrybucję treści.

== Porównanie infrastruktury platform streamingowych
Porównanie ograniczono do trzech serwisów transmisji na żywo: YouTube, Twitch i Kick. Kryterium nie jest zestaw funkcji społecznościowych, lecz droga obrazu: protokół wejścia, przygotowanie profili dla widza, opisane publicznie opóźnienie oraz to, czy czat jest osobnym kanałem względem strumienia wideo. Zestawienie zebrano w #tab(<platformy-infra>).

#tabela(
  [Infrastruktura publicznie opisana przez platformy transmisji na żywo],
  table(
    columns: (1.3fr, 1.6fr, 1.8fr, 1.8fr, 1.5fr),
    align: (left, left, left, left, left),
    [Platforma], [Wejście nadawcy], [Dystrybucja], [Opóźnienie], [Czat],
    [YouTube], [RTMP oraz HLS], [segmenty HLS; tryb ultra-niskiego opóźnienia wyłączany przy wejściu HLS], [poniżej 10 s albo poniżej 5 s dla większości widzów, zależnie od trybu], [osobne API czatu na żywo],
    [Twitch], [RTMP do serwera ingestu], [wiele profili jakości przygotowywanych po wejściu do sieci], [tryb niskiego opóźnienia włączony domyślnie; liczba sekund niepodana], [osobny protokół względem obrazu],
    [Kick], [RTMPS, wyłącznie H.264 i stały bitrate], [brak publicznego opisu drabiny transkodowania i sieci dostarczania], [brak publicznego progu w sekundach], [brak publicznego opisu transportu],
  ),
  zrodlo: [opracowanie własne na podstawie dokumentacji YouTube, Twitch i centrum pomocy Kick],
) <platformy-infra>

YouTube przyjmuje strumień kodera albo playlistę HLS. Przy wejściu HLS opcja ultra-niskiego opóźnienia jest wyłączona, ponieważ materiał jest dzielony na segmenty, a nie wysyłany jako ciągły strumień RTMP #cite(<youtube_hls_ingest>). Dla transmisji interaktywnej serwis publikuje dwa progi: w trybie niskiego opóźnienia większość widzów obserwuje opóźnienie mniejsze niż 10 s, a w trybie ultra-niskim mniejsze niż 5 s. Niższe opóźnienie zwiększa ryzyko buforowania i nie obejmuje rozdzielczości 4K #cite(<youtube_latency>). Czat na żywo jest osobnym zasobem API, niezależnym od ścieżki obrazu #cite(<youtube_live_chat>).

Twitch przyjmuje obraz protokołem RTMP pod adresem serwera ingestu, a klucz transmisji służy do autoryzacji wejścia #cite(<twitch_stream_key>). Po wejściu do sieci materiał źródłowy jest przekształcany tak, aby widz mógł odebrać go na różnych urządzeniach i w różnych profilach jakości #cite(<twitch_broadcast_health>). Tryb niskiego opóźnienia jest na większości kanałów włączony domyślnie i można go wyłączyć; dokumentacja nie podaje liczbowego progu tego trybu #cite(<twitch_low_latency>). Czat jest opisany osobno względem strumienia wideo i opiera się na protokole IRC (ang. _Internet Relay Chat_) #cite(<twitch_chat>).

Kick w centrum pomocy określa wymagania kodera: wyłącznie H.264, stały bitrate, przepływność od 1 000 kb/s do 8 000 kb/s, rozdzielczość do 1920×1080 i do 60 klatek na sekundę. Wejście odbywa się po RTMPS #cite(<kick_how_to_stream>) #cite(<kick_obs>). Centrum pomocy nie opisuje drabiny transkodowania, sieci dostarczania treści ani protokołu czatu. Tych braków nie uzupełniano opisami spoza tej dokumentacji.

Z tabeli wynika, że YouTube jako jedyny z trzech serwisów publikuje liczbowe progi opóźnienia i wprost wiąże niższe opóźnienie z większym ryzykiem buforowania. Twitch i YouTube rozdzielają drogę nadawcy od przygotowania profili dla widza. Kick dokumentuje wyłącznie warunki przyjęcia strumienia.

== Porównanie usług chmurowych
Porównanie dostawców wykonano pod to samo zadanie: przyjęcie transmisji na żywo, transkodowanie nagrania, magazyn obiektowy, dostarczanie treści oraz kolejka zadań. Kryterium wyboru nie jest ogólna ocena dostawcy, lecz obecność własnej usługi dla każdego z tych pięciu elementów. Zestawienie zawiera #tab(<chmury-uslugi>). Kierunkiem realizacji pozostaje Amazon Web Services, ponieważ w jednym koncie dostarcza własną usługę kodowania na żywo, transkodowania plików, magazynu obiektowego, sieci dostarczania i kolejki.

#tabela(
  [Usługi chmurowe przydatne przy budowie platformy transmisji],
  table(
    columns: (1.2fr, 1.5fr, 1.5fr, 1.3fr, 1.4fr, 1.3fr),
    align: left,
    [Dostawca], [Na żywo], [Nagranie], [Magazyn], [Dostarczanie], [Kolejka],
    [AWS], [MediaLive; IVS jako wariant zarządzany], [MediaConvert], [S3], [CloudFront], [SQS],
    [Azure], [brak usługi własnej od 30 czerwca 2024], [brak usługi własnej od 30 czerwca 2024], [Blob Storage], [Front Door], [Service Bus],
    [Google Cloud], [Live Stream API], [Transcoder API], [Cloud Storage], [Media CDN], [Pub/Sub],
    [Alibaba Cloud], [ApsaraVideo Live], [ApsaraVideo VOD], [OSS], [CDN przy odtwarzaniu VOD], [Simple Message Queue],
  ),
  zrodlo: [opracowanie własne na podstawie dokumentacji AWS, Microsoft, Google Cloud i Alibaba Cloud],
) <chmury-uslugi>

=== Amazon Web Services
AWS Elemental MediaLive koduje wideo na żywo i tworzy wyjścia do emisji oraz strumieniowania #cite(<aws_medialive>). Niskie opóźnienie od kamery do widza dokumentacja opisuje jako połączenie MediaLive z AWS Elemental MediaPackage w wersji 2. Ten sam podręcznik MediaPackage podaje, że zwykły HLS ma zwykle opóźnienie od 18 s do 30 s, a HLS o niskim opóźnieniu może zejść do 3–5 s #cite(<aws_mediapackage_hls>). Amazon Interactive Video Service jest osobną usługą zarządzaną do interaktywnej transmisji na żywo, a nie zamiennikiem transkodowania plików #cite(<aws_ivs>).

Transkodowanie pliku nagrania należy do AWS Elemental MediaConvert. Usługa nie przyjmuje sygnału na żywo; do kodowania na żywo dokumentacja odsyła do MediaLive #cite(<aws_mediaconvert_faq>). Amazon Elastic Transcoder nie jest narzędziem do wdrożenia: AWS zakończył wsparcie tej usługi 13 listopada 2025 #cite(<aws_elastic_transcoder_eol>).

Pliki binarne pozostają w Amazon S3 #cite(<s3_api>). Amazon CloudFront dostarcza je z lokalizacji brzegowych jako sieć dostarczania treści #cite(<aws_cloudfront>). Zadania asynchroniczne może przyjąć Amazon SQS (ang. _Simple Queue Service_), czyli zarządzana kolejka komunikatów #cite(<aws_sqs>). Wcześniej opisany RabbitMQ pozostaje wariantem kolejki prowadzonej samodzielnie, a SQS wariantem bez własnego brokera.

=== Microsoft Azure
Microsoft wycofał Azure Media Services 30 czerwca 2024. Po tej dacie konta przestały strumieniować, a kodowanie na żądanie, transmisja na żywo i ochrona treści wymagają rozwiązania partnerskiego albo innej usługi Azure #cite(<azure_ams_retirement>). Własnego następcy o tym samym zakresie dokumentacja nie wskazuje.

Magazyn obiektowy pozostaje dostępny jako Azure Blob Storage i jest przeznaczony do dużych ilości danych bez ustalonego schematu, w tym danych binarnych #cite(<azure_blob>). Dostarczanie treści Microsoft kieruje na Azure Front Door. Klasyczny Azure CDN od Microsoftu jest na ścieżce wycofania do 30 września 2027, a Front Door jest opisywany jako jego następca, z pamięcią podręczną w punktach obecności i równoważeniem ruchu w warstwie aplikacji #cite(<azure_cdn>). Kolejkę i model publikacji z subskrypcjami udostępnia Azure Service Bus #cite(<azure_service_bus>).

=== Google Cloud
Live Stream API przyjmuje sygnał SRT (ang. _Secure Reliable Transport_) albo RTMP, transkoduje go do HLS lub DASH i zapisuje wynik w zasobniku Cloud Storage. Dokumentacja wskazuje następnie Media CDN jako sposób dostarczenia tego zasobnika do widzów #cite(<gcp_livestream>). Transcoder API dotyczy plików: materiał wgrywa się do Cloud Storage, a wynik transkodowania, w tym HLS i DASH, wraca do magazynu #cite(<gcp_transcoder>). Magazyn obiektowy stanowi Cloud Storage. Zdarzenia między usługami przenosi Pub/Sub #cite(<gcp_pubsub>).

=== Alibaba Cloud
ApsaraVideo Live nagrywa transmisję do ApsaraVideo VOD. VOD zarządza tak powstałym materiałem, może go transkodować i wystawia odtwarzanie przyspieszane przez CDN #cite(<alibaba_live_vod>). Magazyn VOD jest oparty na Object Storage Service; można użyć zasobnika zarządzanego przez VOD albo własnego zasobnika OSS #cite(<alibaba_vod_storage>). Kolejkę komunikatów udostępnia Simple Message Queue, z modelem kolejki dla punktu do punktu oraz tematu dla publikacji i subskrypcji #cite(<alibaba_mns>).

=== Wniosek z porównania dostawców
Trzech dostawców, AWS, Google Cloud i Alibaba Cloud, ma własną usługę transmisji na żywo i własną usługę transkodowania nagrań. Azure po 30 czerwca 2024 nie ma już własnej usługi medialnej o tym zakresie, więc ścieżka obrazu wymagałaby produktu partnera. Przy przyjętym kryterium, czyli komplecie usług własnych i jednym kierunku wdrożenia, do dalszych rozdziałów przyjmuje się AWS. Porównanie nie oznacza budowy globalnej sieci dostarczania w ramach tej pracy. CloudFront pozostaje tu usługą odniesienia, nie zakresem implementacji.

== Usługi wspomagające wdrożenie
Poza ścieżką obrazu porównano narzędzia, które porządkują wdrożenie, przekazywanie zadań i obserwację systemu. Nie wchodzą one do zakresu implementacji opisanego w rozdziale o celu pracy. Służą do uzasadnienia, które klasy mechanizmów są potrzebne, jeśli platforma ma być powtarzalna w utrzymaniu.

=== Infrastruktura jako kod i potok dostarczania
Terraform opisuje infrastrukturę jako kod: stan środowiska powstaje z plików konfiguracyjnych, a nie z ręcznej sekwencji w konsoli #cite(<terraform_intro>). Jenkins automatyzuje budowanie i dostarczanie oprogramowania w potoku ciągłej integracji #cite(<jenkins_intro>). Oba narzędzia adresują inny problem niż MediaLive czy S3. Terraform dotyczy zasobów, Jenkins dotyczy wydań aplikacji. Pełna automatyzacja produkcyjnego potoku pozostaje poza zakresem pracy.

=== Kolejki komunikatów
RabbitMQ, wskazany wcześniej przy zadaniach ciężkich, rozdziela nadawców i odbiorców przez wymiany i kolejki w modelu AMQP #cite(<amqp_model>). Apache Kafka jest systemem strumieni zdarzeń: producenci zapisują rekordy do tematów, a grupy konsumentów czytają te tematy niezależnie #cite(<kafka_intro>). Dla zadań o zakończonym czasie życia, takich jak przetworzenie obrazu albo przeniesienie nagrania, wystarcza kolejka zadań. Kafka jest zasadna tam, gdzie wielu odbiorców czyta ten sam, uporządkowany dziennik zdarzeń. W tym zestawieniu nie zastępuje ona RabbitMQ ani SQS, tylko pokazuje drugi model przekazywania komunikatów.

=== Obserwowalność oraz identyfikacja żądań
Prometheus zbiera szeregi czasowe metryk przez pobieranie ich z punktów końcowych #cite(<prometheus_overview>). Grafana składa te szeregi w panele #cite(<grafana_intro>). Loki indeksuje logi po etykietach, a nie po pełnej treści każdej linii #cite(<loki_overview>). Zabbix jest osobnym systemem monitorowania, opartym na agentach i własnym modelu zbierania danych #cite(<zabbix_about>). Pierwsza trójka rozdziela metryki, prezentację i logi. Zabbix łączy zbieranie i alarmowanie w jednym produkcie. Do mierników z rozdziału o celu wystarczają metryki opóźnienia, odsetka błędów i liczby sesji, niezależnie od tego, który z tych produktów je zbierze.

Powiązanie logów jednej operacji umożliwia nagłówek kontekstu śledzenia `traceparent`, określony przez W3C (ang. _World Wide Web Consortium_) #cite(<w3c_trace_context>). Ponowienie tego samego żądania zapisu bez zdublowania skutku opisuje nagłówek `Idempotency-Key` w projekcie grupy roboczej HTTPAPI #cite(<ietf_idempotency>). Oba mechanizmy są praktyką interfejsu HTTP, a nie usługą chmurową.

== Wnioski z analizy konkurencji
Przegląd rozwiązań rynkowych wskazuje, że skuteczne platformy nie opierają się na jednym uniwersalnym mechanizmie, lecz łączą wyspecjalizowane komponenty: protokoły niskiej latencji dla transmisji na żywo, adaptacyjną dystrybucję HTTP dla skali masowej, odrębne kanały komunikacji społecznościowej, warstwę danych w pamięci operacyjnej dla stanu ulotnego, broker kolejek dla zadań ciężkich oraz magazyn obiektowy dla zasobów binarnych.

YouTube i Twitch potwierdzają rozdział wejścia nadawcy od dystrybucji do widza. Kick dokumentuje warunki wejścia, ale nie publikuje opisu dalszej drogi obrazu. Z dostawców chmury komplet własnych usług pod przyjęte kryteria mają AWS, Google Cloud i Alibaba Cloud. Do realizacji wybrano AWS, z MediaLive albo IVS po stronie transmisji na żywo, MediaConvert po stronie nagrań oraz S3 i kolejką po stronie plików i zadań. Elastic Transcoder nie wchodzi do tego zestawu, bo wsparcie usługi zakończono.

Analiza ta potwierdza, że przewagę konkurencyjną buduje nie pojedyncza technologia, ale spójna integracja wielu usług wraz z mechanizmami monitoringu, automatyzacji i skalowania.
