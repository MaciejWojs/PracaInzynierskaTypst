// Wartości liczbowe wspólne dla rozdziałów — źródło: parametry.yaml w tym katalogu.
#let _cfg = yaml("parametry.yaml")
#let _to = _cfg.test_obciazenia
#let _kr = _cfg.kryteria

#let nadawcy-docelowi = _to.nadawcy_docelowi
#let odbiorcy-docelowi = _to.odbiorcy_docelowi
#let rampa-kroki = _to.rampa
#let opoznienie-obrazu-max-s = _kr.opoznienie_obrazu_max_s

#let odbiorcy-na-transmisje = calc.quo(odbiorcy-docelowi, nadawcy-docelowi)

#let profil-skrot = str(nadawcy-docelowi) + "/" + str(odbiorcy-docelowi)

#let rampa-skrot-slasha = {
  let parts = rampa-kroki.map(k => str(k.nadawcy) + "/" + str(k.odbiorcy))
  parts.join(", ")
}

#let rampa-krok-tekst(k) = [#str(k.nadawcy) nadawców i #str(k.odbiorcy) odbiorców]

#let rampa-etapy-tekst = {
  let parts = rampa-kroki.map(k => rampa-krok-tekst(k))
  [na przykład etapami #parts.join([, następnie ])]
}

#let profil-docelowy-krotko = [co najmniej #nadawcy-docelowi jednoczesnych nadawców transmisji na żywo oraz co najmniej #odbiorcy-docelowi jednoczesnych odbiorców łącznie]

#let profil-docelowy-z-rozkladem = [#profil-docelowy-krotko, rozłożonych na te transmisje (średnio około #odbiorcy-na-transmisje odbiorców na jedną transmisję)]

#let tabela-zalozenie-sesje = [profil docelowy: #nadawcy-docelowi nadawców i #odbiorcy-docelowi odbiorców; rampa etapowa do tego składu]

#let tabela-zalozenie-opoznienie = [nie więcej niż #opoznienie-obrazu-max-s s]

#let zrodlo-tabela-mierniki = [opracowanie własne; próg #opoznienie-obrazu-max-s s jako założenie na podstawie opisu trybu niskiego opóźnienia YouTube]
