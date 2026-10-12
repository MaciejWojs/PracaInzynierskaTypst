#import "/szablon/template.typ": rysunek, rys

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

== Planowana architektura systemu
Planowana architektura systemu została zaprojektowana jako zestaw wzajemnie uzupełniających się warstw. Kluczowym celem jest oddzielenie ruchu wejściowego, warstwy aplikacyjnej, serwera transmisji, przechowywania obiektów oraz przetwarzania asynchronicznego. Poniższe diagramy obrazują najważniejsze sekwencje i strumienie danych.

=== Wejście żądania do systemu
W planowanej architekturze systemu kluczową rolę pełni warstwa równoważenia obciążenia, realizowana przez dedykowany serwer pośredniczący. To właśnie ten komponent stanowi centralny punkt wejścia dla wszystkich klientów, przyjmując zarówno żądania HTTP, jak i połączenia WebRTC. Jego zadaniem jest rozdzielanie ruchu do odpowiednich części systemu, zgodnie z typem żądania oraz ścieżką dostępu.

W przypadku żądań HTTP serwer pośredniczący analizuje ścieżkę i przekazuje ruch:
- do serwera aplikacyjnego — dla tras niepowiązanych bezpośrednio z zasobami multimedialnymi;
- do magazynu obiektowego — dla żądań dotyczących plików wideo i zdjęć (na przykład pobieranie lub przesyłanie materiałów);
- do serwera transmisji — dla żądań związanych z oglądaniem transmisji strumieniowanych (na przykład DASH, ang. _Dynamic Adaptive Streaming over HTTP_, lub HLS).

Połączenia WebRTC, inicjowane przez klientów w celu oglądania transmisji na żywo, są kierowane bezpośrednio do serwera transmisji, który obsługuje zarówno przyjmowanie, jak i dystrybucję strumieni. Dodatkowo serwer pośredniczący obsługuje wewnętrzne żądania autoryzacyjne pomiędzy serwerem aplikacyjnym a warstwą pośredniczącą, zapewniając spójność mechanizmów uwierzytelniania i autoryzacji.

Takie rozdzielenie ruchu pozwala na:
- optymalizację ścieżek krytycznych (na przykład streaming wideo nie obciąża warstwy aplikacyjnej);
- łatwiejsze skalowanie poszczególnych komponentów niezależnie od siebie;
- uproszczenie zarządzania bezpieczeństwem i autoryzacją na poziomie centralnego punktu wejścia.

Podział ten ilustruje diagram na #rys(<loadbalancer>).

#rysunek(
  image("sources/loadbalancer.png", width: 90%),
  [Widok planowanego wejścia żądania do systemu z serwerem pośredniczącym],
) <loadbalancer>

=== Separacja warstw danych
Na #rys(<database-sequence>) przedstawiono uproszczoną sekwencję dostępu do danych, która ilustruje podział odpowiedzialności pomiędzy warstwą serwisową, repozytorium, warstwą pośredniczącą pamięci podręcznej oraz bezpośrednim dostępem do bazy danych. Taki model umożliwia oddzielenie logiki biznesowej od szczegółów implementacyjnych trwałego przechowywania oraz wprowadza mechanizmy optymalizujące wydajność.

Proces rozpoczyna się od wywołania metody repozytorium przez warstwę serwisową lub kontroler. Repozytorium w pierwszej kolejności sprawdza, czy żądane dane znajdują się w warstwie pamięci podręcznej (na przykład w pamięci operacyjnej lub zewnętrznym magazynie klucz–wartość). Jeśli dane są dostępne i aktualne, są natychmiast zwracane do klienta, co minimalizuje opóźnienia i odciąża bazę danych.

W przypadku braku danych w pamięci podręcznej lub ich nieaktualności repozytorium deleguje zapytanie do warstwy dostępu do danych (DAO, ang. _Data Access Object_), która realizuje właściwe zapytanie do bazy danych (na przykład poprzez procedury lub funkcje). Po uzyskaniu wyniku dane są zwracane do repozytorium, które aktualizuje pamięć podręczną i przekazuje wynik do warstwy wywołującej.

Takie podejście zapewnia:
- spójność typów i separację odpowiedzialności pomiędzy warstwami;
- możliwość testowania i migracji schematów bazy danych;
- optymalizację wydajności dzięki wykorzystaniu pamięci podręcznej;
- elastyczność w zarządzaniu polityką odświeżania i walidacji danych.

#rysunek(
  image("sources/DatabaseSequence.png", width: 90%),
  [Sekwencja dostępu do danych przy użyciu warstwy DAO i repozytorium],
) <database-sequence>

=== Sekwencja aktualizacji zasobu obrazu
Na #rys(<image-asset-update>) przedstawiono szczegółową sekwencję aktualizacji zasobu obrazu, na przykład podczas zmiany zdjęcia profilowego przez użytkownika. Proces ten został zaprojektowany w taki sposób, aby operacje kosztowne obliczeniowo i operacje wejścia-wyjścia były realizowane asynchronicznie, poza ścieżką krytyczną żądania użytkownika.

Całość rozpoczyna się od żądania HTTP wysłanego przez użytkownika do serwera aplikacyjnego, zawierającego nowe dane obrazu. Serwer, po wstępnej walidacji, nie przetwarza pliku bezpośrednio, lecz umieszcza zadanie w kolejce zadań (na przykład poprzez brokera wiadomości). Zadanie to zawiera niezbędne informacje do dalszego przetwarzania (na przykład identyfikator użytkownika, skrót pliku, metadane).

Broker zadań przekazuje komunikat do wyspecjalizowanego procesu roboczego, odpowiedzialnego za operacje na plikach multimedialnych. Proces roboczy wykonuje wymagane przekształcenia, takie jak generowanie różnych rozdzielczości obrazu, kompresję czy walidację formatu. Po zakończeniu przetwarzania nowe pliki są przesyłane do magazynu obiektowego.

Po pomyślnym zakończeniu operacji proces roboczy informuje brokera o statusie zadania, a ten przekazuje aktualizację do serwera aplikacyjnego. W rezultacie możliwa jest aktualizacja indeksów metadanych oraz zapisanie nowego adresu pliku w bazie danych.

Takie podejście zapewnia:
- oddzielenie ścieżki krytycznej żądania użytkownika od operacji kosztownych obliczeniowo i operacji wejścia-wyjścia;
- wysoką responsywność API nawet przy dużym obciążeniu;
- możliwość skalowania procesów roboczych niezależnie od serwera aplikacyjnego;
- spójność i aktualność indeksów metadanych dzięki asynchronicznej obsłudze statusów zadań.

#rysunek(
  image("sources/ImageAssetUpdate.png", width: 90%),
  [Sekwencja aktualizacji zasobu obrazu, łącznie z walidacją i zapisem do magazynu],
) <image-asset-update>

=== Sekwencja zakończenia streamowania
Na #rys(<stream-ended>) przedstawiono szczegółową sekwencję obsługi zakończenia transmisji na żywo oraz przetwarzania nagranego materiału wideo. Proces ten został zaprojektowany w sposób asynchroniczny, aby zapewnić wysoką wydajność i spójność systemu przy równoległej obsłudze wielu transmisji.

Po zakończeniu transmisji serwer strumieniowania informuje serwer aplikacyjny o gotowości pliku wideo do dalszego przetwarzania. Serwer aplikacyjny, zamiast wykonywać operacje bezpośrednio, umieszcza zadanie w kolejce zadań (na przykład poprzez brokera wiadomości), przekazując niezbędne informacje o zakończonym streamie (identyfikator, lokalizacja pliku).

Broker zadań przekazuje komunikat do procesu roboczego, który pobiera plik wideo z serwera strumieniowania, wykonuje ewentualne przetwarzanie (na przykład konwersję, kompresję) i przesyła gotowy plik do magazynu obiektowego. Po zakończeniu operacji proces roboczy usuwa oryginalny plik z serwera transmisji, zwalniając zasoby dyskowe.

Po pomyślnym zakończeniu zadania proces roboczy informuje brokera, a ten przekazuje aktualizację do serwera aplikacyjnego. W rezultacie możliwa jest aktualizacja stanu systemu oraz zapisanie nowego adresu pliku w bazie danych, co umożliwia dalszą dystrybucję materiału.

Takie podejście zapewnia:
- asynchroniczne i niezawodne przetwarzanie nagrań;
- automatyczne zwalnianie zasobów po zakończeniu transmisji;
- spójność stanu systemu nawet przy wielu równoległych operacjach;
- możliwość dalszego skalowania procesów roboczych niezależnie od serwera aplikacyjnego.

#rysunek(
  image("sources/StreamEnded.png", width: 90%),
  [Sekwencja zakończenia streamowania i zwalniania zasobów],
) <stream-ended>

=== Ogólny schemat przepływu architektury
Na #rys(<flowchart>) przedstawiono ogólny schemat architektury. Diagram ilustruje główne komponenty, kierunki przepływu danych oraz punkt styku pomiędzy warstwą czasu rzeczywistego, warstwą aplikacyjną i magazynem obiektowym. Taki model ułatwia analizę punktów skalowania oraz identyfikację potencjalnych wąskich gardeł.

#rysunek(
  image("sources/flowchart.png", width: 90%),
  [Ogólny schemat planowanej architektury systemu],
) <flowchart>

== Wnioski z analizy konkurencji
Przegląd rozwiązań rynkowych wskazuje, że skuteczne platformy nie opierają się na jednym uniwersalnym mechanizmie, lecz łączą wyspecjalizowane komponenty: protokoły niskiej latencji dla transmisji na żywo, adaptacyjną dystrybucję HTTP dla skali masowej, odrębne kanały komunikacji społecznościowej, warstwę danych w pamięci operacyjnej dla stanu ulotnego, broker kolejek dla zadań ciężkich oraz magazyn obiektowy dla zasobów binarnych.

Analiza ta potwierdza, że przewagę konkurencyjną buduje nie pojedyncza technologia, ale spójna integracja wielu usług wraz z mechanizmami monitoringu, automatyzacji i skalowania.
