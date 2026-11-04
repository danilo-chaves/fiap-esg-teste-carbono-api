# language: pt
@regressivo
Funcionalidade: Compensação e integridade ambiental
  Como responsável ambiental
  Quero registrar e consultar compensações
  Para manter a integridade dos registros de compensação

  @positivo @esg @contrato
  Cenário: Registrar compensação de carbono
    Dado que possuo uma empresa exclusiva
    Quando registro uma compensação de 40 tCO2e
    Então o status deve ser 201
    E a resposta deve respeitar o contrato "compensacao"
    Então o campo "quantidadeTco2e" deve valer 40
    E o campo "empresaId" deve ser "${empresaId}"
    E o campo "tipo" deve ser "REFLORESTAMENTO"

  @positivo @esg @contrato
  Cenário: Localizar compensação na listagem
    Dado que possuo uma empresa exclusiva
    E que registrei uma compensação de 40 tCO2e
    Quando envio GET para "/compensacao-carbono?sort=id,desc&size=100"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "pagina-compensacao"
    E a página deve conter o id salvo em "compensacaoId"

  @negativo @esg @contrato
  Esquema do Cenário: Rejeitar compensação com <motivo>
    Dado que possuo uma empresa exclusiva
    Quando envio POST para "/compensacao-carbono" com o JSON:
      """
      {"empresaId":${empresaId},"quantidadeTco2e":<quantidade>,"tipo":"REFLORESTAMENTO","dataCompensacao":"<data>"}
      """
    Então o status deve ser 400
    E a resposta deve respeitar o contrato "erro"
    E o erro deve apontar o campo "<campo>"

    Exemplos:
      | motivo          | quantidade | data       | campo           |
      | valor negativo  | -1         | ${hoje}    | quantidadeTco2e |
      | data futura     | 1          | ${futuro}  | dataCompensacao |
