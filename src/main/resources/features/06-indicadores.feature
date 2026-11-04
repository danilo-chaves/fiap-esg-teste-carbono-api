# language: pt
@regressivo
Funcionalidade: Precisão dos indicadores ESG
  Como gestor de sustentabilidade
  Quero consultar os indicadores de carbono
  Para avaliar o saldo líquido e o impacto das metas

  @positivo @esg @contrato
  Cenário: Conferir saldo por diferença de totais
    Dado que possuo uma empresa exclusiva
    E que capturei o saldo líquido inicial
    E que registrei uma emissão de 100 tCO2e
    E que registrei uma compensação de 40 tCO2e
    Quando envio GET para "/indicadores-sustentabilidade"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "indicadores"
    E o saldo líquido deve aumentar 60 tCO2e

  @positivo @esg @contrato
  Cenário: Calcular impacto de meta sobre emissão da empresa
    Dado que possuo um agendamento exclusivo
    E que registrei uma emissão de 100 tCO2e
    Quando envio GET para "/impacto-mitigacao/${agendamentoId}"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "impacto"
    E o campo "agendamentoId" deve ser "${agendamentoId}"
    E o campo "metaReducaoTco2e" deve valer 25
    E o campo "totalEmitidoEmpresa" deve valer 100
    E o campo "percentualImpacto" deve valer 25

  @positivo @esg @contrato
  Cenário: Retornar impacto zero sem emissões
    Dado que possuo um agendamento exclusivo
    Quando envio GET para "/impacto-mitigacao/${agendamentoId}"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "impacto"
    E o campo "totalEmitidoEmpresa" deve valer 0
    E o campo "percentualImpacto" deve valer 0

  @negativo @esg @contrato
  Cenário: Consultar impacto de agendamento inexistente
    Dado que estou autenticado como ADMIN
    Quando envio GET para "/impacto-mitigacao/9223372036854775807"
    Então o status deve ser 404
    E a resposta deve respeitar o contrato "erro"
