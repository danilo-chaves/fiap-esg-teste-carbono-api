# Matriz de cobertura

Prefixo de todas as rotas: `/api/v1`. A cobertura mede operações HTTP declaradas, não linhas ou todos os ramos de negócio.

| Método | Rota | Feature | Status | Schema | Verificação funcional |
|---|---|---|---|---|---|
| POST | /auth/login | 01-autenticacao | 200 / 400 / 401 | login / erro | JWT, email, role e senha incorreta |
| GET | /empresas-sustentaveis | 02-empresas | 200 / 403 | pagina-empresa | ID cadastrado na lista; acesso anônimo |
| GET | /empresas-sustentaveis/{id} | 02-empresas | 200 / 404 | empresa / erro | ID exato e recurso inexistente |
| POST | /empresas-sustentaveis | 02-empresas | 201 / 400 / 409 / 403 | empresa / erro | Dados persistidos, CNPJ duplicado e perfil AUDITOR |
| GET | /emissoes-carbono | 03-emissoes | 200 | pagina-emissao | ID da emissão na lista |
| GET | /historico-emissoes/{empresaId} | 03-emissoes | 200 | pagina-emissao | Histórico não vazio, ID e vínculo com empresa |
| POST | /relatorio-emissao | 03-emissoes | 201 / 400 / 404 | emissao / erro | Quantidade, escopo, vínculo, valor negativo e data futura |
| GET | /agendamento-reducao-carbono | 04-agendamentos | 200 | pagina-agendamento | ID do plano na lista |
| POST | /agendamento-reducao-carbono | 04-agendamentos | 201 / 400 / 422 | agendamento / erro | PENDENTE, meta, ordem das datas e meta zero |
| PUT | /agendamento-reducao-carbono/{id} | 04-agendamentos | 200 / 422 | agendamento / erro | Título, meta e status atualizados; bloqueio após cancelamento |
| DELETE | /agendamento-reducao-carbono/{id} | 04-agendamentos | 204 / 422 | vazio / erro | Corpo vazio, cancelamento lógico e repetição |
| GET | /compensacao-carbono | 05-compensacoes | 200 | pagina-compensacao | ID da compensação na lista |
| POST | /compensacao-carbono | 05-compensacoes | 201 / 400 | compensacao / erro | Quantidade, tipo, vínculo, valor negativo e data futura |
| GET | /indicadores-sustentabilidade | 06-indicadores | 200 | indicadores | Variação do saldo: 100 emitidos - 40 compensados = 60 |
| GET | /impacto-mitigacao/{id} | 06-indicadores e 04-agendamentos | 200 / 404 | impacto / erro | 25 / 100 x 100 = 25%; zero sem emissão; cancelamento |

Total: 15 operações; 34 cenários executáveis; 12 schemas. O contrato de erro é aplicado a respostas JSON de negócio. Para bloqueios no filtro de segurança, só há expectativa de status 403; para 204, valida-se corpo vazio.
