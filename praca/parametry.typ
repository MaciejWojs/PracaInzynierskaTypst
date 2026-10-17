// Wartości liczbowe wspólne dla rozdziałów — źródło: parametry.yaml w tym katalogu.
#let _cfg = yaml("parametry.yaml")
#let _to = _cfg.test_obciazenia
#let _kr = _cfg.kryteria
#let _lim = _cfg.limity_aws

#let nadawcy-docelowi = _to.nadawcy_docelowi
#let odbiorcy-docelowi = _to.odbiorcy_docelowi
#let rampa-kroki = _to.rampa
#let usluga-obrazu = _cfg.usluga_obrazu
#let zapas = _cfg.zapas

// --- limity i kontrola profilu --------------------------------------------

#let limit-strumieni = if usluga-obrazu == "ivs" { _lim.ivs_wspolbiezne_strumienie } else { _lim.medialive_kanaly }
#let limit-widokow = _lim.ivs_wspolbiezne_widoki
#let _fmt(n) = {
  let t = str(n)
  let out = ""
  let len = t.len()
  for (i, c) in t.clusters().enumerate() {
    if i > 0 and calc.rem(len - i, 3) == 0 { out += "\u{00A0}" }
    out += c
  }
  out
}
#let limit-ivs-strumieni = _fmt(_lim.ivs_wspolbiezne_strumienie)
#let limit-ivs-widokow = _fmt(_lim.ivs_wspolbiezne_widoki)
#let limit-medialive-kanalow = _fmt(_lim.medialive_kanaly)
#let limit-apigw-rps = _fmt(_lim.apigw_przepustowosc_rps)
#let limit-strumieni-z-zapasem = calc.floor(limit-strumieni * zapas)
#let limit-widokow-z-zapasem = calc.floor(limit-widokow * zapas)

#assert(
  usluga-obrazu in ("ivs", "medialive"),
  message: "parametry.yaml: usluga_obrazu musi być ivs albo medialive",
)
#assert(
  nadawcy-docelowi <= limit-strumieni-z-zapasem,
  message: "parametry.yaml: nadawcy_docelowi przekraczają limit strumieni AWS z zapasem (" + str(limit-strumieni-z-zapasem) + ")",
)
#assert(
  odbiorcy-docelowi <= limit-widokow-z-zapasem,
  message: "parametry.yaml: odbiorcy_docelowi przekraczają limit widoków AWS z zapasem (" + str(limit-widokow-z-zapasem) + ")",
)
#for k in rampa-kroki {
  assert(
    k.nadawcy <= nadawcy-docelowi and k.odbiorcy <= odbiorcy-docelowi,
    message: "parametry.yaml: etap rampy przekracza profil docelowy",
  )
}

// --- progi kryteriów -------------------------------------------------------

#let opoznienie-obrazu-max-s = _kr.opoznienie_obrazu_max_s
#let opoznienie-czatu-p95-max-ms = _kr.opoznienie_czatu_p95_max_ms
#let czas-api-p95-max-ms = _kr.czas_odpowiedzi_api_p95_max_ms
#let nieudane-odtworzenia-max-proc = _kr.odsetek_nieudanych_odtworzen_max_proc
#let pierwsza-klatka-max-s = _kr.czas_do_pierwszej_klatki_max_s

#let _zr(klucz) = if _kr.at(klucz) == "literatura" { [próg z przeglądu] } else { [założenie własne] }

// --- wartości pochodne i fragmenty tekstu ---------------------------------

#let odbiorcy-na-transmisje = calc.quo(odbiorcy-docelowi, nadawcy-docelowi)
#let profil-skrot = str(nadawcy-docelowi) + "/" + str(odbiorcy-docelowi)
#let udzial-strumieni-proc = calc.round(nadawcy-docelowi / limit-strumieni * 100)
#let udzial-widokow-proc = calc.round(odbiorcy-docelowi / limit-widokow * 100)
#let zapas-proc = calc.round(zapas * 100)

#let rampa-skrot-slasha = {
  let parts = rampa-kroki.map(k => str(k.nadawcy) + "/" + str(k.odbiorcy))
  parts.join(", ")
}

#let profil-docelowy-krotko = [co najmniej #nadawcy-docelowi jednoczesnych nadawców transmisji na żywo oraz co najmniej #odbiorcy-docelowi jednoczesnych odbiorców łącznie]

#let profil-docelowy-z-rozkladem = [#profil-docelowy-krotko, rozłożonych na te transmisje (średnio około #odbiorcy-na-transmisje odbiorców na jedną transmisję)]

// Komórki tabeli mierników.
#let tabela-zalozenie-sesje = [profil docelowy: #nadawcy-docelowi nadawców i #odbiorcy-docelowi odbiorców; rampa etapowa do tego składu]
#let tabela-zalozenie-opoznienie = [nie więcej niż #opoznienie-obrazu-max-s s (#_zr("opoznienie_obrazu_zrodlo"))]
#let tabela-zalozenie-pierwsza-klatka = [nie więcej niż #pierwsza-klatka-max-s s (#_zr("czas_do_pierwszej_klatki_zrodlo"))]
#let tabela-zalozenie-czat = [95. percentyl nie więcej niż #opoznienie-czatu-p95-max-ms ms (#_zr("opoznienie_czatu_zrodlo"))]
#let tabela-zalozenie-api = [95. percentyl nie więcej niż #czas-api-p95-max-ms ms (#_zr("czas_odpowiedzi_api_zrodlo"))]
#let tabela-zalozenie-odtworzenia = [nie więcej niż #nieudane-odtworzenia-max-proc% (#_zr("odsetek_nieudanych_odtworzen_zrodlo"))]

#let zrodlo-tabela-mierniki = [opracowanie własne; próg opóźnienia obrazu na podstawie opisu trybu niskiego opóźnienia YouTube, pozostałe wartości oznaczono w tabeli]

// Zdanie o zgodności profilu z limitami AWS.
#let zgodnosc-z-limitami = [Profil docelowy to #udzial-strumieni-proc% domyślnego limitu jednoczesnych strumieni oraz #udzial-widokow-proc% limitu jednoczesnych widoków wybranej usługi, przy założonym zapasie #zapas-proc% limitu.]
