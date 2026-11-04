# Verificações da preparação do CI

- Repositório de testes consultado via git ls-remote: acessível e sem refs no momento da preparação. Nenhum push foi realizado.
- API consultada via Git e clonada em modo de leitura. Commit: e2f28b435eb25c41dd882089d9bd3dc84cbff704. Comparação binária do pom.xml e de todos os arquivos de src/ com a API validada do pacote: sem diferenças.
- Workflow validado com actionlint 1.7.7, sem erros. Integrações opcionais shellcheck e pyflakes não foram executadas por esse linter.
- YAML verificado: eventos push/pull_request/workflow_dispatch, permissão contents: read, execução Oracle, cleanup e upload em always().
- Verificador de relatório exercitado com JSON real histórico, usando suas contagens próprias de 25 cenários e 168 passos: aprovado. Casos de falha, skipped, pending, undefined, hook falho, JSON inválido, arquivo ausente e contagens divergentes: rejeitados. Não há execução artificial apresentada como resultado funcional.
- Links locais do README e sintaxe Bash de run-oracle.sh conferidos.
- A execução real no GitHub ainda precisa ocorrer após o primeiro push. A validação estática não comprova disponibilidade do runner, download das imagens ou aprovação dos testes em CI.
