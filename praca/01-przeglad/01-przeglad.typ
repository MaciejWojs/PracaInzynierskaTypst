#import "/szablon/template.typ": tabela, tab
#import "/praca/parametry.typ": limit-ivs-strumieni, limit-ivs-widokow, limit-medialive-kanalow, limit-apigw-rps

= Przegląd technologii i istniejących rozwiązań
W tym rozdziale przedstawiono rozwiązania publicznie opisane przez platformy transmisji na żywo oraz technologie, z których można zbudować podobny system. Punkt ciężkości położono na aspekty, które bezpośrednio wpływają na jakość transmisji, skalowalność i stabilność działania: transport wideo, komunikację czasu rzeczywistego, warstwę danych oraz przetwarzanie asynchroniczne. Opisy wnętrza platform ograniczono do tego, co podają ich dokumentacje.

== Platformy transmisji na żywo: droga obrazu
YouTube Live #cite(<youtube_live_encoder>) i Twitch #cite(<twitch_broadcast_guidelines>) w swoich dokumentacjach opisują transmisję jako dwie ścieżki: wejście nadawcy do punktu przyjęcia strumienia oraz dystrybucję do widzów w wielu profilach jakości. Droga nadawcy jest więc rozdzielona od drogi widza. Szczegóły ścieżki obrazu u poszczególnych platform zestawiono w dalszej części rozdziału.

Do odtwarzania masowego powszechnie stosuje się segmentację opartą o HLS (ang. _HTTP Live Streaming_) #cite(<hls_apple>), która współpracuje z siecią dostarczania treści CDN (ang. _Content Delivery Network_). Część usług udostępnia tryby o obniżonym opóźnieniu, na przykład Twitch #cite(<twitch_low_latency>) i YouTube #cite(<youtube_latency>). Według YouTube niższe opóźnienie oznacza mniejszy bufor odtwarzacza i większe ryzyko buforowania.

W obszarze WebRTC (ang. _Web Real-Time Communication_) standaryzowane są protokoły wejścia i wyjścia: WHIP (ang. _WebRTC-HTTP Ingestion Protocol_) #cite(<whip_rfc>) oraz WHEP (ang. _WebRTC-HTTP Egress Protocol_) #cite(<whep_draft>). Upraszczają one sygnalizację i ograniczają liczbę niestandardowych integracji po stronie klienta.

== Komunikacja społecznościowa: WebSocket i SSE
Dokumentacje YouTube i Twitch opisują czat jako kanał odrębny od strumienia obrazu #cite(<youtube_live_chat>) #cite(<twitch_chat>). Taki podział ma sens technicznie: ruch czatu i reakcji ma inną charakterystykę niż ruch wideo. Komunikację dwukierunkową w przeglądarce zapewnia WebSocket #cite(<websockets_book>). Jednokierunkowe komunikaty serwisowe, na przykład o starcie transmisji, może przesyłać SSE (ang. _Server-Sent Events_) #cite(<sse_spec>). Wystarcza on do zdarzeń rozsyłanych od serwera do klienta.

Z przeglądu wynika podział na dwie klasy ruchu: komunikację konwersacyjną i powiadomienia systemowe. Rozdzielenie ich zmniejsza obciążenie pojedynczego mechanizmu transportowego i upraszcza skalowanie poziome.

== Infrastruktura czasu rzeczywistego: proxy, WAF i serwery multimedialne
System czasu rzeczywistego można rozłożyć na warstwy: brzegową (proxy i WAF, ang. _Web Application Firewall_), sesji (serwery aplikacyjne i WebSocket), multimedialną (ingest, transkodowanie, dystrybucja) oraz asynchroniczną. W wariancie samodzielnym warstwę brzegową tworzy Nginx jako reverse proxy i mechanizm równoważenia obciążenia #cite(<nginx_lb>) oraz ModSecurity jako WAF #cite(<nginx_waf>).

W warstwie multimedialnej przykładem rozwiązania samodzielnego jest SRS (ang. _Simple Realtime Server_) w wersji 6 #cite(<srs_v6_docs>). Dokumentacja opisuje go jako serwer łączący ingest, transkodowanie i dystrybucję oraz obsługujący protokoły WebRTC i HLS #cite(<srs_docs>).

W WebRTC zestawianie połączeń użytkowników za NAT (ang. _Network Address Translation_) wymaga warstwy ICE (ang. _Interactive Connectivity Establishment_), a więc infrastruktury STUN (ang. _Session Traversal Utilities for NAT_) i w razie potrzeby TURN (ang. _Traversal Using Relays around NAT_) #cite(<webrtc_spec>).

== Dane ulotne i skalowanie WebSocket
Dane krótkiego życia, takie jak sesje, tokeny, liczniki widzów czy blokady krótkoterminowe, przechowuje się zwykle w magazynie w pamięci operacyjnej, na przykład Redis #cite(<redis_docs>) lub Valkey #cite(<valkey_docs>), a nie w bazie relacyjnej. Mechanizm publikacji i subskrypcji pozwala przekazywać zdarzenia WebSocket między instancjami aplikacji. Użytkownik może wtedy być podłączony do dowolnego węzła i otrzymywać zdarzenia danego kanału, bez przywiązania do jednej instancji.

== Kolejki i zadania ciężkie
Operacje krytyczne czasowo oddziela się od zadań obciążających procesor (CPU, ang. _Central Processing Unit_) lub wejście-wyjście (I/O, ang. _Input/Output_). Typowym przykładem są operacje na obrazach użytkownika: walidacja pliku, generowanie kilku rozdzielczości, kompresja i zapis do magazynu. Można je realizować przez broker wiadomości RabbitMQ #cite(<rabbitmq_docs>) w modelu AMQP (ang. _Advanced Message Queuing Protocol_) #cite(<amqp_model>) z procesami roboczymi. Dzięki kolejce kosztowne obliczeniowo zadania nie obciążają ścieżki krytycznej żądań API (ang. _Application Programming Interface_).

== Magazyn obiektowy
Do przechowywania plików binarnych służy magazyn obiektowy zgodny z API S3 #cite(<s3_api>). Zgodność protokołu implementują także rozwiązania samodzielne, na przykład MinIO #cite(<minio_docs>). W takim magazynie przechowuje się materiały VOD (ang. _Video on Demand_), miniatury transmisji i obrazy profilowe, niezależnie od warstwy aplikacyjnej.

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
AWS Elemental MediaLive koduje wideo na żywo i tworzy wyjścia do emisji oraz strumieniowania #cite(<aws_medialive>). AWS Elemental MediaPackage w wersji 2 udostępnia HLS oraz LL-HLS (ang. _Low-Latency HLS_). Podręcznik MediaPackage podaje, że zwykły HLS ma zwykle opóźnienie od 18 s do 30 s, a LL-HLS może zejść do 3–5 s #cite(<aws_mediapackage_hls>). Amazon Interactive Video Service (IVS) jest osobną usługą zarządzaną do interaktywnej transmisji na żywo: dokumentacja podaje, że kanały IVS mogą dostarczać obraz z opóźnieniem poniżej 5 s oraz przyjmują wejście RTMP, RTMPS i SRT #cite(<aws_ivs>). IVS nie służy do transkodowania plików.

Transkodowanie pliku nagrania należy do AWS Elemental MediaConvert. Usługa nie przyjmuje sygnału na żywo; do kodowania na żywo dokumentacja odsyła do MediaLive #cite(<aws_mediaconvert_faq>). Amazon Elastic Transcoder nie jest narzędziem do wdrożenia: AWS ogłosił zakończenie wsparcia tej usługi z dniem 13 listopada 2025 #cite(<aws_elastic_transcoder_eol>).

Pliki binarne pozostają w Amazon S3 #cite(<s3_api>). Amazon CloudFront dostarcza je z lokalizacji brzegowych jako sieć dostarczania treści #cite(<aws_cloudfront>). Zadania asynchroniczne może przyjąć Amazon SQS (ang. _Simple Queue Service_), czyli zarządzana kolejka komunikatów #cite(<aws_sqs>). Wcześniej opisany RabbitMQ pozostaje wariantem kolejki prowadzonej samodzielnie, a SQS wariantem bez własnego brokera.

=== Microsoft Azure
Microsoft wycofał Azure Media Services 30 czerwca 2024. Po tej dacie konta przestały strumieniować, a kodowanie na żądanie, transmisja na żywo i ochrona treści wymagają rozwiązania partnerskiego albo innej usługi Azure #cite(<azure_ams_retirement>). Własnego następcy o tym samym zakresie dokumentacja nie wskazuje.

Magazyn obiektowy pozostaje dostępny jako Azure Blob Storage i jest przeznaczony do dużych ilości danych bez ustalonego schematu, w tym danych binarnych #cite(<azure_blob>). Dostarczanie treści Microsoft kieruje na Azure Front Door. Usługa Azure CDN Standard from Microsoft (classic) jest wycofywana z dniem 30 września 2027, a Microsoft zaleca migrację do Azure Front Door Standard albo Premium #cite(<azure_cdn>). Kolejkę i model publikacji z subskrypcjami udostępnia Azure Service Bus #cite(<azure_service_bus>).

=== Google Cloud
Live Stream API przyjmuje sygnał SRT (ang. _Secure Reliable Transport_) albo RTMP, transkoduje go do HLS lub DASH i zapisuje wynik w zasobniku Cloud Storage. Dokumentacja wskazuje następnie Media CDN jako sposób dostarczenia tego zasobnika do widzów #cite(<gcp_livestream>). Transcoder API dotyczy plików: materiał wgrywa się do Cloud Storage, a wynik transkodowania, w tym HLS i DASH, wraca do magazynu #cite(<gcp_transcoder>). Magazyn obiektowy stanowi Cloud Storage. Zdarzenia między usługami przenosi Pub/Sub #cite(<gcp_pubsub>).

=== Alibaba Cloud
ApsaraVideo Live nagrywa transmisję do ApsaraVideo VOD. VOD zarządza tak powstałym materiałem, może go transkodować i wystawia odtwarzanie przyspieszane przez CDN #cite(<alibaba_live_vod>). Magazyn VOD jest oparty na Object Storage Service; można użyć zasobnika zarządzanego przez VOD albo własnego zasobnika OSS #cite(<alibaba_vod_storage>). Kolejkę komunikatów udostępnia Simple Message Queue, z modelem kolejki dla punktu do punktu oraz tematu dla publikacji i subskrypcji #cite(<alibaba_mns>).

=== Usługa obrazu w AWS: IVS i MediaLive
Do transmisji na żywo w AWS wchodzą w grę dwie usługi: MediaLive (kodowanie i wyjścia, zwykle z MediaPackage) oraz IVS (kanały z zarządzaną dystrybucją). Dla projektu liczy się też to, ile jednoczesnych transmisji i widoków dopuszczają domyślne limity konta. Zestawienie podaje #tab(<ivs-medialive>).

#tabela(
  [Usługi obrazu w AWS i domyślne limity konta w regionie],
  table(
    columns: (1.4fr, 1.7fr, 1.7fr),
    align: left,
    [Cecha], [Amazon IVS (Low-Latency)], [AWS Elemental MediaLive],
    [Jednostka zasobu], [kanał], [kanał],
    [Jednoczesne transmisje], [#limit-ivs-strumieni (jednoczesne strumienie)], [#limit-medialive-kanalow (kanały na region)],
    [Jednoczesne widoki], [#limit-ivs-widokow], [brak limitu w tej usłudze; dystrybucja przez MediaPackage lub CDN],
    [Opóźnienie według dokumentacji], [poniżej 5 s], [zależy od wyjścia; LL-HLS w MediaPackage 3–5 s],
    [Zwiększenie limitu], [możliwe], [możliwe],
  ),
  zrodlo: [opracowanie własne na podstawie dokumentacji AWS #cite(<aws_ivs_quotas>) #cite(<aws_medialive_quotas>) #cite(<aws_ivs>) #cite(<aws_mediapackage_hls>)],
) <ivs-medialive>

Przy domyślnych limitach MediaLive dopuszcza pięć kanałów w regionie, więc przetestowanie kilkudziesięciu jednoczesnych transmisji wymagałoby wniosku o zwiększenie limitu. IVS dopuszcza sto jednoczesnych strumieni i piętnaście tysięcy jednoczesnych widoków bez zmian konfiguracji konta. Limity te dotyczą konta i regionu i mogą się różnić na koncie docelowym, dlatego przed testami należy je porównać z konsolą Service Quotas. Do testów skalowania wynika z tego wybór IVS, a MediaLive zostaje wariantem dla bardziej rozbudowanej ścieżki kodowania. Krótkie żądania HTTP objęte są z kolei limitem przepustowości API Gateway na konto, który wynosi domyślnie #limit-apigw-rps żądań na sekundę w większości regionów #cite(<aws_apigw_quotas>).

=== Wniosek z porównania dostawców
Trzech dostawców, AWS, Google Cloud i Alibaba Cloud, ma własną usługę transmisji na żywo i własną usługę transkodowania nagrań. Azure po 30 czerwca 2024 nie ma już własnej usługi medialnej o tym zakresie, więc ścieżka obrazu wymagałaby produktu partnera. Przy przyjętym kryterium, czyli komplecie usług własnych i jednym kierunku wdrożenia, do dalszych rozdziałów przyjmuje się AWS. Porównanie nie oznacza budowy globalnej sieci dostarczania w ramach tej pracy. CloudFront pozostaje tu usługą odniesienia, nie zakresem implementacji.

== Usługi wspomagające wdrożenie
Poza ścieżką obrazu porównano narzędzia, które porządkują wdrożenie, przekazywanie zadań i obserwację systemu. Zebranie mierników opisanych w rozdziale celu należy do zakresu pracy: Prometheus pobiera szeregi, a Grafana składa panele. GitOps, Terraform, Loki i Jenkins są dodatkiem. Nie rozstrzygają o spełnieniu celu.

=== Infrastruktura jako kod i potok dostarczania
GitOps utrzymuje deklarowany stan środowiska: agenty pobierają wersję z repozytorium i uzgadniają stan rzeczywisty z deklarowanym #cite(<opengitops>). Terraform opisuje infrastrukturę jako kod: stan środowiska powstaje z plików konfiguracyjnych, a nie z ręcznej sekwencji w konsoli #cite(<terraform_intro>). Jenkins automatyzuje budowanie i dostarczanie oprogramowania w potoku ciągłej integracji #cite(<jenkins_intro>). Terraform dotyczy zasobów, Jenkins dotyczy wydań aplikacji. Pełna automatyzacja produkcyjnego potoku pozostaje poza celem pracy.

=== Kolejki komunikatów
RabbitMQ, wskazany wcześniej przy zadaniach ciężkich, rozdziela nadawców i odbiorców przez wymiany i kolejki w modelu AMQP #cite(<amqp_model>). Apache Kafka jest systemem strumieni zdarzeń: producenci zapisują rekordy do tematów, a grupy konsumentów czytają te tematy niezależnie #cite(<kafka_intro>). Dla zadań o zakończonym czasie życia, takich jak przetworzenie obrazu albo przeniesienie nagrania, wystarcza kolejka zadań. Kafka jest zasadna tam, gdzie wielu odbiorców czyta ten sam, uporządkowany dziennik zdarzeń. W tym zestawieniu nie zastępuje ona RabbitMQ ani SQS, tylko pokazuje drugi model przekazywania komunikatów.

=== Obserwowalność oraz identyfikacja żądań
Prometheus zbiera szeregi czasowe metryk przez pobieranie ich z punktów końcowych #cite(<prometheus_overview>). Grafana składa te szeregi w panele #cite(<grafana_intro>). Do mierników z rozdziału celu przyjęto tę parę: opóźnienie, odsetek błędów i liczbę sesji. Loki indeksuje logi po etykietach, a nie po pełnej treści każdej linii #cite(<loki_overview>). Zabbix jest osobnym systemem monitorowania, opartym na agentach i własnym modelu zbierania danych #cite(<zabbix_about>). Loki i Zabbix zostają porównaniem. Do celu pracy nie wchodzą.

Powiązanie logów jednej operacji umożliwia nagłówek kontekstu śledzenia `traceparent`, określony przez W3C (ang. _World Wide Web Consortium_) #cite(<w3c_trace_context>). Ponowienie tego samego żądania zapisu bez zdublowania skutku opisuje nagłówek `Idempotency-Key` w projekcie grupy roboczej HTTPAPI #cite(<ietf_idempotency>). Oba mechanizmy są praktyką interfejsu HTTP, a nie usługą chmurową.

== Kryteria oceny platform i systemów strumieniowania
Kryteria oceny własnego systemu wyznaczono na podstawie wartości publikowanych przez platformy i dostawców chmury. Zestawienie dla opóźnienia i limitów skali podaje #tab(<kryteria-u-innych>). Dla pozostałych mierników analizowane dokumentacje nie publikują progów liczbowych, co także zapisano w tabeli.

#tabela(
  [Kryteria oceny i wartości publikowane przez platformy i dostawców],
  table(
    columns: (1.5fr, 2.4fr, 1.4fr),
    align: left,
    [Kryterium], [Wartość opublikowana], [Źródło],
    [Opóźnienie obrazu, tryb niskiego opóźnienia], [większość widzów poniżej 10 s (YouTube); ultra-niskie opóźnienie poniżej 5 s], [dokumentacja YouTube],
    [Opóźnienie obrazu, rozwiązania zarządzane], [LL-HLS 3–5 s (MediaPackage); kanały IVS poniżej 5 s], [dokumentacja AWS],
    [Opóźnienie obrazu, Twitch i Kick], [brak liczbowego progu w dokumentacji], [dokumentacja platform],
    [Skala jednoczesnych transmisji i widoków], [IVS: #limit-ivs-strumieni strumieni i #limit-ivs-widokow widoków; MediaLive: #limit-medialive-kanalow kanałów], [limity usług AWS],
    [Czas do pierwszej klatki, odsetek nieudanych odtworzeń, opóźnienie czatu, czas odpowiedzi API], [brak progów liczbowych w analizowanych dokumentacjach], [do ustalenia jako założenie własne],
  ),
  zrodlo: [opracowanie własne na podstawie dokumentacji YouTube #cite(<youtube_latency>), AWS #cite(<aws_mediapackage_hls>) #cite(<aws_ivs>) #cite(<aws_ivs_quotas>) #cite(<aws_medialive_quotas>), Twitch #cite(<twitch_low_latency>) i Kick #cite(<kick_how_to_stream>)],
) <kryteria-u-innych>

Z tabeli wynika, że jedyne wartości liczbowe opóźnienia pochodzą od YouTube i usług AWS. Próg opóźnienia obrazu w rozdziale celu opiera się więc na tych źródłach. Progi pozostałych mierników w rozdziale celu są założeniami własnymi autora i wymagają akceptacji promotora. Zestawienia w #tab(<platformy-infra>) i #tab(<chmury-uslugi>) pokazują natomiast, które cechy ścieżki obrazu są publicznie udokumentowane. Kryteria zostały więc określone przed testami własnego systemu, a nie dobrane po zebraniu wyników.

== Wnioski z przeglądu
Przegląd rozwiązań rynkowych wskazuje, że skuteczne platformy nie opierają się na jednym uniwersalnym mechanizmie, lecz łączą wyspecjalizowane komponenty: protokoły niskiej latencji dla transmisji na żywo, adaptacyjną dystrybucję HTTP dla skali masowej, odrębne kanały komunikacji społecznościowej, warstwę danych w pamięci operacyjnej dla stanu ulotnego, broker kolejek dla zadań ciężkich oraz magazyn obiektowy dla zasobów binarnych.

YouTube i Twitch potwierdzają rozdział wejścia nadawcy od dystrybucji do widza. Kick dokumentuje warunki wejścia, ale nie publikuje opisu dalszej drogi obrazu. Z dostawców chmury komplet własnych usług pod przyjęte kryteria mają AWS, Google Cloud i Alibaba Cloud. Do realizacji wybrano AWS. Domyślne limity IVS (#limit-ivs-strumieni jednoczesnych strumieni, #limit-ivs-widokow widoków) mieszczą planowany profil testu skalowania, a limit MediaLive (#limit-medialive-kanalow kanałów) go nie mieści bez wniosku o zwiększenie, dlatego po stronie transmisji na żywo przyjmuje się IVS. Nagrania obsługuje MediaConvert, a pliki i zadania S3 i kolejka. Elastic Transcoder nie wchodzi do tego zestawu, bo wsparcie usługi zakończono.

Analiza ta potwierdza, że platforma powstaje przez spięcie usług transmisji, danych i zdarzeń. Zebranie mierników Prometheusem i Grafaną należy do celu pracy. Automatyzacja wdrożenia, w tym GitOps, Terraform i Jenkins, tym celem nie jest.
