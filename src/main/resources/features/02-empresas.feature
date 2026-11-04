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
