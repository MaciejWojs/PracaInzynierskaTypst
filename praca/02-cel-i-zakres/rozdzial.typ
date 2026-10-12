= Cel i zakres pracy
Na podstawie analizy rozwiązań rynkowych oraz technologii wykorzystywanych we współczesnych platformach streamingowych określono cel pracy i zakres działań projektowo-implementacyjnych. W rozdziale doprecyzowano, jakie elementy systemu zostaną zrealizowane, jakie ograniczenia przyjęto oraz według jakich kryteriów będzie oceniany końcowy rezultat.

== Cel pracy
Celem pracy jest zaprojektowanie i zaimplementowanie społecznościowej platformy wideo, która umożliwi prowadzenie transmisji na żywo oraz interakcję użytkowników w czasie rzeczywistym. Opracowywany system ma łączyć warstwę frontendową, backendową i multimedialną, przy jednoczesnym uwzględnieniu wymagań związanych z bezpieczeństwem, wydajnością i możliwością dalszego skalowania.

W ujęciu technicznym realizacja celu obejmuje:
- przygotowanie mechanizmu publikacji i odtwarzania transmisji na żywo;
- zapewnienie funkcji społecznościowych, takich jak czat, reakcje i powiadomienia;
- wdrożenie procesu zapisu transmisji oraz późniejszego udostępniania nagrań;
- zaprojektowanie architektury umożliwiającej skalowanie poziome;
- przeprowadzenie testów funkcjonalnych i wydajnościowych potwierdzających spełnienie przyjętych założeń.

== Zakres funkcjonalny
Zakres funkcjonalny pracy obejmuje implementację najważniejszych procesów biznesowych, które są niezbędne do działania platformy. Po stronie użytkownika przewidziano obsługę rejestracji, logowania i uwierzytelniania, a także mechanizmy autoryzacji zależne od przypisanej roli. System ma również umożliwiać rozpoczęcie i zakończenie transmisji na żywo, jej odtwarzanie przez odbiorców oraz prowadzenie komunikacji tekstowej w ramach czatu transmisji.

Uzupełnieniem podstawowych funkcji będą mechanizmy publikowania reakcji i zdarzeń w czasie rzeczywistym, prezentowania informacji o nowych transmisjach i aktywności serwisu, a także obsługa zapisu materiałów i ich późniejszego udostępniania w formie VOD (ang. _Video on Demand_). Zakres pracy obejmuje również zarządzanie wybranymi zasobami multimedialnymi użytkownika, w szczególności awatarem oraz miniaturą transmisji.

== Zakres architektury i integracji
W ramach pracy przewidziano budowę rozwiązania wielowarstwowego, w którym poszczególne komponenty odpowiadają za odrębne obszary działania systemu. Warstwa frontendowa będzie odpowiedzialna za interfejs użytkownika służący do publikowania i oglądania transmisji oraz do obsługi interakcji społecznościowych. Warstwa backendowa przejmie logikę biznesową, udostępnianie API (ang. _Application Programming Interface_), autoryzację, zarządzanie sesją oraz integrację z pozostałymi usługami.

Istotną część architektury stanowić będzie warstwa czasu rzeczywistego, odpowiedzialna za komunikację z wykorzystaniem WebSocket i SSE (ang. _Server-Sent Events_), oraz warstwa multimedialna, która obsłuży strumieniowanie i nagrywanie transmisji. Uzupełnieniem rozwiązania będą warstwa danych do przechowywania informacji trwałych i ulotnych, warstwa asynchroniczna przeznaczona do realizacji zadań kosztownych obliczeniowo, warstwa plikowa wykorzystująca magazyn obiektowy dla nagrań i zasobów graficznych oraz warstwa brzegowa i bezpieczeństwa obejmująca reverse proxy, równoważenie obciążenia i WAF (ang. _Web Application Firewall_).

W architekturze przyjęto podejście DDD (ang. _Domain-Driven Design_) oraz kontrakty danych DTO (ang. _Data Transfer Object_) z walidacją wejścia. Przyjęcie takiego modelu ma ułatwić oddzielenie domeny biznesowej od warstwy infrastrukturalnej, a w konsekwencji zwiększyć przejrzystość rozwiązania i ułatwić jego dalszy rozwój.

== Zakres technologiczny
Zakres technologiczny obejmuje zastosowanie kilku grup narzędzi i mechanizmów, które wspólnie tworzą podstawę projektowanego systemu. W warstwie klienckiej i serwerowej wykorzystane zostaną technologie webowe odpowiedzialne za budowę interfejsu oraz logiki aplikacyjnej. W obszarze transmisji przewidziano użycie protokołów służących do ingestu i dystrybucji wideo, w tym rozwiązań niskolatencyjnych i adaptacyjnych.

Dodatkowo zastosowane zostaną mechanizmy komunikacji czasu rzeczywistego, magazyn w pamięci operacyjnej przeznaczony do obsługi stanu ulotnego i propagacji zdarzeń, broker kolejek do realizacji zadań asynchronicznych oraz magazyn kompatybilny z API S3 do przechowywania plików binarnych. Zakres technologiczny uzupełniają rozwiązania odpowiedzialne za bezpieczeństwo ruchu HTTP (ang. _Hypertext Transfer Protocol_) i ochronę aplikacyjną.

== Zakres testów i walidacji
W celu potwierdzenia poprawności działania systemu przewidziano realizację testów w dwóch głównych obszarach: funkcjonalnym oraz wydajnościowym. Testy funkcjonalne posłużą do weryfikacji poprawności scenariuszy użytkownika i oceny, czy najważniejsze funkcje platformy działają zgodnie z założeniami. Z kolei testy wydajnościowe pozwolą ocenić zachowanie systemu przy rosnącym obciążeniu oraz wskazać potencjalne ograniczenia projektowe.

W zakresie testów funkcjonalnych uwzględnione zostaną między innymi proces logowania, uruchamianie transmisji, odbiór obrazu i dźwięku, działanie czatu, publikacja reakcji oraz zapis materiału VOD. Testy wydajnościowe obejmą natomiast analizę czasu odpowiedzi API, opóźnień dostarczania zdarzeń czasu rzeczywistego, obciążenia serwera strumieniowania oraz stabilności działania systemu przy zwiększonej liczbie użytkowników.

== Zakres poza pracą
W ramach niniejszej pracy nie przewiduje się realizacji wszystkich elementów, które mogłyby wystąpić w dojrzałym wdrożeniu produkcyjnym. Poza zakresem pozostaje budowa globalnej infrastruktury CDN (ang. _Content Delivery Network_), wdrożenie komercyjnych mechanizmów monetyzacji, pełna automatyzacja procesu ciągłej integracji i dostarczania na poziomie produkcyjnym, przygotowanie natywnych aplikacji mobilnych oraz formalna certyfikacja bezpieczeństwa systemu.

Elementy te należy traktować jako potencjalne kierunki dalszego rozwoju rozwiązania po zakończeniu prac objętych zakresem niniejszej pracy inżynierskiej.

== Element nowatorski i wartość pracy
Wartość opracowania wynika przede wszystkim z połączenia wielu technologii w ramach jednego, spójnego systemu. Nowatorski charakter rozwiązania polega na integracji funkcji społecznościowych z transmisją wideo w czasie rzeczywistym, a także na powiązaniu tej warstwy z architekturą przygotowaną do skalowania i z mechanizmami asynchronicznego przetwarzania danych multimedialnych.

Z punktu widzenia inżynierskiego istotne znaczenie ma również zestawienie warstwy czasu rzeczywistego z mechanizmami przechowywania danych ulotnych i kolejkowania zadań. Takie podejście pozwala ograniczyć opóźnienia odczuwane przez użytkownika, a jednocześnie sprzyja utrzymaniu stabilności działania całego systemu.

== Kryteria osiągnięcia celu
Za potwierdzenie osiągnięcia celu pracy przyjmuje się spełnienie kilku podstawowych kryteriów. Należą do nich poprawne działanie kluczowych funkcji platformy, stabilna obsługa transmisji na żywo i interakcji społecznościowych, a także poprawna realizacja ścieżki zapisu i udostępniania nagrań.

Istotne będzie również uzyskanie pozytywnych wyników testów funkcjonalnych, osiągnięcie akceptowalnych parametrów w testach wydajnościowych oraz przygotowanie spójnej dokumentacji architektury i przebiegu badań. Tak określony cel i zakres wyznaczają ramy dalszych rozdziałów, w których przedstawione zostaną metodyka, implementacja oraz rezultaty badań eksperymentalnych.
