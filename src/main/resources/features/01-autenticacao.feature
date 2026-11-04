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
