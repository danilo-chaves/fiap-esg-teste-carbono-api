# language: pt
@regressivo
Funcionalidade: Registro e histórico de emissões de carbono
  Como responsável ambiental
  Quero registrar e consultar emissões
  Para acompanhar o inventário de carbono da empresa

  @positivo @esg @contrato
  Cenário: Registrar emissão de carbono
    Dado que possuo uma empresa exclusiva
    Quando registro uma emissão de 100 tCO2e
    Então o status deve ser 201
    E a resposta deve respeitar o contrato "emissao"
    Então o campo "quantidadeTco2e" deve valer 100
    E o campo "empresaId" deve ser "${empresaId}"
    E o campo "escopo" deve ser "ESCOPO_1"

  @positivo @esg @contrato
  Cenário: Localizar emissão na listagem
    Dado que possuo uma empresa exclusiva
    E que registrei uma emissão de 100 tCO2e
    Quando envio GET para "/emissoes-carbono?sort=id,desc&size=100"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "pagina-emissao"
    E a página deve conter o id salvo em "emissaoId"

  @positivo @esg @contrato
  Cenário: Consultar histórico de emissões da empresa
    Dado que possuo uma empresa exclusiva
    E que registrei uma emissão de 100 tCO2e
    Quando envio GET para "/historico-emissoes/${empresaId}"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "pagina-emissao"
    E a página deve conter o id salvo em "emissaoId"
    E a página deve pertencer à empresa exclusiva

  @negativo @esg @contrato
  Esquema do Cenário: Rejeitar emissão com <motivo>
    Dado que possuo uma empresa exclusiva
    Quando envio POST para "/relatorio-emissao" com o JSON:
      """
      {"empresaId":${empresaId},"quantidadeTco2e":<quantidade>,"escopo":"ESCOPO_1","dataEmissao":"<data>"}
      """
    Então o status deve ser 400
    E a resposta deve respeitar o contrato "erro"
    E o erro deve apontar o campo "<campo>"

    Exemplos:
      | motivo          | quantidade | data       | campo           |
      | valor negativo  | -1         | ${hoje}    | quantidadeTco2e |
      | data futura     | 1          | ${futuro}  | dataEmissao |

  @negativo @esg @contrato
  Cenário: Rejeitar emissão para empresa inexistente
    Dado que estou autenticado como ADMIN
    Quando envio POST para "/relatorio-emissao" com o JSON:
      """
      {"empresaId":9223372036854775807,"quantidadeTco2e":1,"escopo":"ESCOPO_1","dataEmissao":"${hoje}"}
      """
    Então o status deve ser 404
    E a resposta deve respeitar o contrato "erro"
