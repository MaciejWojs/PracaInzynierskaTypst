#import "/szablon/template.typ": wstep

#wstep[
  Transmisja wideo na żywo w Internecie opiera się na oddzieleniu ścieżki nadawcy od dystrybucji do widzów oraz na protokołach adaptacyjnego strumieniowania po HTTP #cite(<hls_apple>) #cite(<youtube_live_encoder>). Równolegle użytkownicy oczekują interakcji w czasie zbliżonym do rzeczywistego, na przykład w czacie transmisji, co w praktyce wymaga odrębnych kanałów komunikacji względem strumienia obrazu #cite(<youtube_live_chat>).

  W obszarze platform społecznościowych pojawiają się problemy integracji tych warstw: zapewnienie akceptowalnego opóźnienia obrazu, skalowanie sesji czasu rzeczywistego między wieloma instancjami aplikacji oraz utrzymanie stabilności API przy zadaniach asynchronicznych. Niniejsza praca inżynierska dotyczy zaprojektowania i implementacji systemu łączącego transmisję na żywo z funkcjami społecznościowymi; cel, zakres i kryteria oceny określono w kolejnym rozdziale.
]
