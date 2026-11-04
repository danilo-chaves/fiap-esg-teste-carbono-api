# Cenários da etapa 1

Fonte integral para atualizar a seção de cenários do PDF. As evidências de 30/10 pertencem à versão anterior.

## 01-autenticacao

```gherkin
# language: pt
@regressivo
Funcionalidade: Autenticação e governança
  Como ADMIN
  Quero autenticar e aplicar restrições de acesso
  Para proteger os dados e apoiar a governança

  @positivo @governanca @contrato
  Cenário: Autenticar administrador com credenciais válidas
    Dado que estou autenticado como ADMIN
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "login"
    E o campo "role" deve ser "ADMIN"

  @negativo @governanca @contrato
  Cenário: Rejeitar senha incorreta
    Dado que estou sem autenticação
    Quando envio POST para "/auth/login" com o JSON:
      """
      {"email":"${adminEmail}","senha":"senha-incorreta"}
      """
    Então o status deve ser 401
    E a resposta deve respeitar o contrato "erro"
    E o campo "status" deve valer 401
    E o campo "mensagem" deve ser "Email ou senha inválidos"

  @negativo @governanca @contrato
  Cenário: Rejeitar login com email malformado
    Dado que estou sem autenticação
    Quando envio POST para "/auth/login" com o JSON:
      """
      {"email":"invalido","senha":"qualquer"}
      """
    Então o status deve ser 400
    E a resposta deve respeitar o contrato "erro"
    E o erro deve apontar o campo "email"

  @negativo @governanca
  Cenário: Proteger leitura sem token
    Dado que estou sem autenticação
    Quando envio GET para "/empresas-sustentaveis"
    Então o status deve ser 403

  @negativo @governanca
  Cenário: Impedir cadastro pelo auditor
    Dado que estou autenticado como AUDITOR
    Quando envio POST para "/empresas-sustentaveis" com o JSON:
      """
      {"nome":"Bloqueada","cnpj":"${cnpj}","setor":"Energia","pais":"Brasil"}
      """
    Então o status deve ser 403
```

## 02-empresas

```gherkin
# language: pt
@regressivo
Funcionalidade: Cadastro e rastreabilidade de empresas
  Como responsável pelo cadastro
  Quero registrar e consultar empresas
  Para rastrear as informações ambientais por empresa

  @positivo @esg @contrato
  Cenário: Cadastrar empresa
    Dado que estou autenticado como ADMIN
    Quando cadastro uma empresa exclusiva
    Então o status deve ser 201
    E a resposta deve respeitar o contrato "empresa"
    E o campo "nome" deve ser "Empresa BDD"
    E o campo "cnpj" deve ser "${cnpj}"
    E o campo "ativa" deve ser "true"

  @positivo @esg @contrato
  Cenário: Consultar empresa pelo identificador
    Dado que possuo uma empresa exclusiva
    Quando envio GET para "/empresas-sustentaveis/${empresaId}"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "empresa"
    E o campo "id" deve ser "${empresaId}"

  @positivo @esg @contrato
  Cenário: Localizar empresa na listagem
    Dado que possuo uma empresa exclusiva
    Quando envio GET para "/empresas-sustentaveis?sort=id,desc&size=100"
    Então o status deve ser 200
    E a resposta deve respeitar o contrato "pagina-empresa"
    E a página deve conter o id salvo em "empresaId"

  @negativo @esg @contrato
  Cenário: Rejeitar CNPJ duplicado
    Dado que possuo uma empresa exclusiva
    Quando envio POST para "/empresas-sustentaveis" com o JSON:
      """
      {"nome":"Duplicada","cnpj":"${cnpj}","setor":"Energia","pais":"Brasil"}
      """
    Então o status deve ser 409
    E a resposta deve respeitar o contrato "erro"
    E o campo "status" deve valer 409

  @negativo @esg @contrato
  Cenário: Validar campos obrigatórios da empresa
    Dado que estou autenticado como ADMIN
    Quando envio POST para "/empresas-sustentaveis" com o JSON:
      """
      {"nome":"","cnpj":"invalido","setor":"","pais":""}
      """
    Então o status deve ser 400
    E a resposta deve respeitar o contrato "erro"
    E o erro deve apontar o campo "cnpj"
    E o erro deve apontar o campo "nome"

  @negativo @esg @contrato
  Cenário: Consultar empresa inexistente
    Dado que estou autenticado como ADMIN
    Quando envio GET para "/empresas-sustentaveis/9223372036854775807"
    Então o status deve ser 404
    E a resposta deve respeitar o contrato "erro"
    E o campo "status" deve valer 404
```

## 03-emissoes

```gherkin
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
```

## 04-agendamentos

```gherkin
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
```

## 05-compensacoes

```gherkin
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
```

## 06-indicadores

```gherkin
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
```