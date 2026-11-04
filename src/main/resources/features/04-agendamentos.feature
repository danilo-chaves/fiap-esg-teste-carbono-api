# language: pt
@regressivo
Funcionalidade: Planejamento e cancelamento de redução
  Como gestor de sustentabilidade
  Quero gerenciar planos de redução
  Para acompanhar metas e o cancelamento dos planos

  @positivo @esg @contrato
  Cenário: Criar plano de redução
    Dado que possuo uma empresa exclusiva
    Quando cadastro um agendamento exclusivo
    Então o status deve ser 201
    E a resposta deve respeitar o contrato "agendamento"
    E o campo "status" deve ser "PENDENTE"
    E o campo "metaReducaoTco2e" deve valer 25

  @positivo @esg @contrato
  Cenário: Localizar plano na listagem
    Dado que possuo um agendamento exclusivo
    Quando envio GET para "/agendamento-reducao-carbono?sort=id,desc&size=100"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "pagina-agendamento"
    E a página deve conter o id salvo em "agendamentoId"

  @positivo @esg @contrato
  Cenário: Atualizar plano de redução
    Dado que possuo um agendamento exclusivo
    Quando envio PUT para "/agendamento-reducao-carbono/${agendamentoId}" com o JSON:
      """
      {"titulo":"Plano atualizado","metaReducaoTco2e":30,"status":"EM_ANDAMENTO","dataFimPrevista":"${futuro}"}
      """
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "agendamento"
    E o campo "status" deve ser "EM_ANDAMENTO"
    E o campo "titulo" deve ser "Plano atualizado"
    E o campo "metaReducaoTco2e" deve valer 30

  @positivo @esg @contrato
  Cenário: Cancelar plano de redução
    Dado que possuo um agendamento exclusivo
    Quando envio DELETE para "/agendamento-reducao-carbono/${agendamentoId}"
    Então o status deve ser 204
    E o corpo deve estar vazio

  @positivo @esg @contrato
  Cenário: Consultar situação de plano cancelado
    Dado que possuo um agendamento exclusivo
    E que o agendamento está cancelado
    Quando envio GET para "/impacto-mitigacao/${agendamentoId}"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "impacto"
    E o campo "status" deve ser "CANCELADO"

  @negativo @esg @contrato
  Cenário: Impedir novo cancelamento
    Dado que possuo um agendamento exclusivo
    E que o agendamento está cancelado
    Quando envio DELETE para "/agendamento-reducao-carbono/${agendamentoId}"
    Então o status deve ser 422
    E a resposta deve respeitar o contrato "erro"
    E o campo "mensagem" deve ser "Agendamento já está cancelado"

  @negativo @esg @contrato
  Cenário: Impedir atualização de plano cancelado
    Dado que possuo um agendamento exclusivo
    E que o agendamento está cancelado
    Quando envio PUT para "/agendamento-reducao-carbono/${agendamentoId}" com o JSON:
      """
      {"titulo":"Plano atualizado","metaReducaoTco2e":30,"status":"EM_ANDAMENTO","dataFimPrevista":"${futuro}"}
      """
    Então o status deve ser 422
    E a resposta deve respeitar o contrato "erro"
    E o campo "mensagem" deve ser "Não é possível atualizar um agendamento cancelado"

  @negativo @esg @contrato
  Cenário: Rejeitar fim anterior ao início
    Dado que possuo uma empresa exclusiva
    Quando envio POST para "/agendamento-reducao-carbono" com o JSON:
      """
      {"empresaId":${empresaId},"titulo":"Datas inválidas","metaReducaoTco2e":25,"dataInicio":"${futuroMaior}","dataFimPrevista":"${futuro}"}
      """
    Então o status deve ser 422
    E a resposta deve respeitar o contrato "erro"
    E o campo "mensagem" deve ser "Data fim prevista deve ser posterior à data de início"

  @negativo @esg @contrato
  Cenário: Rejeitar meta zero
    Dado que possuo uma empresa exclusiva
    Quando envio POST para "/agendamento-reducao-carbono" com o JSON:
      """
      {"empresaId":${empresaId},"titulo":"Meta inválida","metaReducaoTco2e":0,"dataInicio":"${hoje}","dataFimPrevista":"${futuro}"}
      """
    Então o status deve ser 400
    E a resposta deve respeitar o contrato "erro"
    E o erro deve apontar o campo "metaReducaoTco2e"
