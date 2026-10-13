#import "/szablon/template.typ": rysunek, rys, tabela, tab

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
Aktualna koncepcja rozdziela aplikację od ścieżki obrazu. Warstwa frontendowa obsługuje publikowanie transmisji, odbiór i interakcje społecznościowe. Warstwa backendowa zostaje przy logice konta, autoryzacji, API (ang. _Application Programming Interface_) i czacie. Przyjęcie sygnału na żywo, transkodowanie i dystrybucja do widza przechodzą do usług zarządzanych AWS wskazanych w przeglądzie: MediaLive albo IVS dla transmisji na żywo oraz MediaConvert dla nagrania. Pliki pozostają w S3. Zadania poboczne, takie jak miniatury i domknięcie nagrania, idą kolejką, a nie przez własny serwer strumieniowania.

Czat i powiadomienia zostają osobnym kanałem, opartym na WebSocket i SSE (ang. _Server-Sent Events_), niezależnie od protokołu obrazu. Dane trwałe i pamięć podręczna sesji nie zmieniają roli. Podejście DDD (ang. _Domain-Driven Design_) oraz kontrakty DTO (ang. _Data Transfer Object_) dotyczą warstwy aplikacyjnej, nie kodowania wideo.

Własny serwer pośredniczący, który jednocześnie przyjmuje HTTP, WebRTC i rozdziela strumień do lokalnego serwera transmisji, nie jest już koncepcją docelową. Opis tego układu, razem z dotychczasowymi diagramami, przeniesiono poniżej jako materiał wcześniejszy. Diagramy zostają w pracy do czasu zastąpienia ich schematem usług AWS.

== Wcześniejsza koncepcja architektury
Poprzedni układ zakładał własny zestaw warstw: serwer pośredniczący, serwer transmisji, magazyn obiektowy i procesy robocze. Diagramy tego układu pozostają w pracy, choć nie opisują już zakresu realizacji.

=== Wejście żądania do systemu
We wcześniejszej koncepcji centralnym punktem wejścia był dedykowany serwer pośredniczący. Przyjmował żądania HTTP i połączenia WebRTC oraz rozdzielał ruch według ścieżki.

W przypadku żądań HTTP serwer pośredniczący przekazywał ruch:
- do serwera aplikacyjnego — dla tras niepowiązanych bezpośrednio z zasobami multimedialnymi;
- do magazynu obiektowego — dla żądań dotyczących plików wideo i zdjęć;
- do serwera transmisji — dla odtwarzania transmisji strumieniowanych (na przykład DASH, ang. _Dynamic Adaptive Streaming over HTTP_, lub HLS).

Połączenia WebRTC miały iść bezpośrednio do własnego serwera transmisji. Ten podział ilustruje diagram na #rys(<loadbalancer>).

#rysunek(
  image("../01-przeglad/sources/loadbalancer.png", width: 90%),
  [Wcześniejsza koncepcja wejścia żądania przez serwer pośredniczący],
) <loadbalancer>

=== Separacja warstw danych
Na #rys(<database-sequence>) pokazano sekwencję dostępu do danych: warstwa serwisowa, repozytorium, pamięć podręczna i baza. Ta część nie zależy od wyboru usługi medialnej i pozostaje aktualna dla warstwy aplikacyjnej.

Repozytorium najpierw sprawdza pamięć podręczną. Przy braku danych albo ich nieaktualności zapytanie idzie przez warstwę DAO (ang. _Data Access Object_) do bazy, a wynik wraca do pamięci podręcznej.

#rysunek(
  image("../01-przeglad/sources/DatabaseSequence.png", width: 90%),
  [Sekwencja dostępu do danych przy użyciu warstwy DAO i repozytorium],
) <database-sequence>

=== Sekwencja aktualizacji zasobu obrazu
Na #rys(<image-asset-update>) pokazano aktualizację obrazu, na przykład awatara, poza ścieżką krytyczną żądania. Serwer aplikacyjny odkłada zadanie do kolejki, proces roboczy wykonuje przekształcenia i zapisuje plik w magazynie, a następnie aktualizowane są metadane. Ten przebieg zostaje także w koncepcji opartej na AWS, ze zmianą magazynu na S3 i kolejki na usługę zarządzaną albo na dotychczasowy broker.

#rysunek(
  image("../01-przeglad/sources/ImageAssetUpdate.png", width: 90%),
  [Sekwencja aktualizacji zasobu obrazu we wcześniejszej koncepcji],
) <image-asset-update>

=== Sekwencja zakończenia streamowania
Na #rys(<stream-ended>) pokazano zakończenie transmisji w układzie z własnym serwerem strumieniowania. Serwer ten zgłaszał gotowość pliku, a proces roboczy pobierał nagranie, przenosił je do magazynu i usuwał kopię z serwera transmisji. W aktualnej koncepcji ten krok wykonuje usługa kodowania i magazyn S3, bez własnego serwera transmisji jako miejsca składowania pliku.

#rysunek(
  image("../01-przeglad/sources/StreamEnded.png", width: 90%),
  [Sekwencja zakończenia streamowania we wcześniejszej koncepcji],
) <stream-ended>

=== Ogólny schemat przepływu architektury
Na #rys(<flowchart>) zestawiono komponenty wcześniejszego układu: warstwę czasu rzeczywistego, warstwę aplikacyjną i magazyn obiektowy. Schemat nie obejmuje MediaLive, IVS, MediaConvert ani S3 i zostanie zastąpiony po opracowaniu diagramu aktualnej koncepcji.

#rysunek(
  image("../01-przeglad/sources/flowchart.png", width: 90%),
  [Ogólny schemat wcześniejszej architektury systemu],
) <flowchart>

== Zakres technologiczny
Warstwa kliencka i serwerowa aplikacji pozostaje przy technologiach webowych. Transmisja na żywo korzysta z usługi zarządzanej AWS, MediaLive albo IVS, a nagranie z MediaConvert. Pliki binarne trafiają do S3. Czat i powiadomienia korzystają z kanału dwukierunkowego oraz z jednokierunkowych zdarzeń serwera. Stan ulotny i propagacja zdarzeń między instancjami aplikacji zostają w magazynie w pamięci operacyjnej. Zadania asynchroniczne idą kolejką. Ochrona ruchu HTTP zostaje przy warstwie aplikacyjnej. Własny serwer strumieniowania i własna sieć dostarczania treści nie wchodzą do zakresu.

== Zakres testów i walidacji
W celu potwierdzenia poprawności działania systemu przewidziano realizację testów w dwóch głównych obszarach: funkcjonalnym oraz wydajnościowym. Testy funkcjonalne posłużą do weryfikacji poprawności scenariuszy użytkownika i oceny, czy najważniejsze funkcje platformy działają zgodnie z założeniami. Z kolei testy wydajnościowe pozwolą ocenić zachowanie systemu przy rosnącym obciążeniu oraz wskazać potencjalne ograniczenia projektowe.

W zakresie testów funkcjonalnych uwzględnione zostaną między innymi proces logowania, uruchamianie transmisji, odbiór obrazu i dźwięku, działanie czatu, publikacja reakcji oraz zapis materiału VOD. Testy wydajnościowe obejmą natomiast analizę czasu odpowiedzi API, opóźnień dostarczania zdarzeń czasu rzeczywistego, obciążenia serwera strumieniowania oraz stabilności działania systemu przy zwiększonej liczbie użytkowników.

== Zakres poza pracą
W ramach niniejszej pracy nie przewiduje się realizacji wszystkich elementów, które mogłyby wystąpić w dojrzałym wdrożeniu produkcyjnym. Poza zakresem pozostaje budowa globalnej infrastruktury CDN (ang. _Content Delivery Network_), wdrożenie komercyjnych mechanizmów monetyzacji, pełna automatyzacja procesu ciągłej integracji i dostarczania na poziomie produkcyjnym, przygotowanie natywnych aplikacji mobilnych oraz formalna certyfikacja bezpieczeństwa systemu.

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
- przerwa jednej instancji aplikacji nie przerywa przyjętego już strumienia w warstwie multimedialnej.

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

Test funkcjonalny potwierdza kolejne wiersze wymagań funkcjonalnych. Test obciążenia zapisuje mierniki opóźnienia, czasu odpowiedzi i liczby sesji. Wyników tych testów ten rozdział nie podaje. Tak określony cel i zakres wyznaczają ramy dalszych rozdziałów, w których przedstawione zostaną metodyka, implementacja oraz rezultaty badań.
