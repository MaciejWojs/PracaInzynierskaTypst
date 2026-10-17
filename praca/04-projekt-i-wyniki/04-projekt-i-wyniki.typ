#import "/praca/parametry.typ": profil-docelowy-krotko

= Projekt, implementacja i weryfikacja
Rozdział prezentuje kolejne etapy projektowania oraz implementacji opracowanego rozwiązania. Należy wykazać funkcjonalność i użyteczność systemu, wkład własny autora oraz zestawienie uzyskanych wyników z kryteriami i miernikami określonymi w rozdziale „Cel i zakres pracy”.

== Projekt i implementacja
W tym podrozdziale opisano architekturę przyjętą w pracy, wybrane technologie oraz najważniejsze moduły zaimplementowane przez autora. Prezentacja obejmuje warstwę aplikacyjną, integrację z usługami multimedialnymi, mechanizmy czasu rzeczywistego oraz przetwarzanie asynchroniczne. Szczegóły implementacji uzupełniają rysunki i listingi kodu, do których odsyła tekst główny.

== Weryfikacja względem kryteriów
Weryfikację przeprowadzono według metodyki z poprzedniego rozdziału. Wyniki testów funkcjonalnych potwierdzają spełnienie wymagań z rozdziału celu. Wyniki testów obciążeniowych zestawiono z miernikami z tabeli kryteriów: opóźnienie obrazu, czas odpowiedzi API, opóźnienie zdarzeń czatu, liczba utrzymanych sesji przy profilu docelowym (#profil-docelowy-krotko; oraz na etapach rampy) oraz stabilność odtwarzania. Wartości liczbowe po zakończeniu badań uzupełnią tabele i wykresy w tym podrozdziale; wnioski końcowe powiążą się z tymi samymi kryteriami w podsumowaniu.
