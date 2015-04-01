module Use
  # uso (use) fogli 8 e 9
  CLI_DOMEST   = "clienti_domestici"
  CONDO_U_DOM  = "condominio_uso_dom"

  # uso foglio "10.UR ALTRI CLIENTI"
  OTHER_USES   = "clienti_altri_usi"
  PUBLIC_SERV  = "servizio_pubblico"

  def uses_for_8_9
    [CLI_DOMEST, CONDO_U_DOM]
  end
end