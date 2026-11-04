# Etapa 1 — itens 3, 6, 7, 8 e 9

Implementação: narrativas em seis features; cenários separados por operação; dois esquemas de cenário com dois exemplos cada; tags de seleção. Resultado estrutural: 34 cenários, 188 passos, 17 positivos e 17 negativos.

O pacote exclui target, .idea, .git e .env. Fontes e pom da API permanecem iguais aos recebidos. O projeto de teste continua autônomo. Credenciais eventualmente presentes nos fontes originais da API não foram alteradas; revisar antes de publicação pública.

Validação realizada: parser/compilador Gherkin oficial 42.0.1 e Cucumber Expressions Python 20.1.0; cada passo possui uma única definição correspondente. Não é execução da suíte Java. A tentativa Maven foi bloqueada pelo acesso às dependências; o ambiente disponível possui Java 17, enquanto o projeto exige JDK 21.

## Validar localmente no Git Bash com JDK 21

```bash
cd teste-carbono-api
mkdir -p evidencias/etapa1
set -o pipefail
bash scripts/run-local.sh 2>&1 | tee evidencias/etapa1/execucao-maven.txt
```

Após BUILD SUCCESS, copiar target/cucumber-reports.html, target/cucumber.json, target/cucumber.xml e target/surefire-reports para evidencias/etapa1/. Atualizar o PDF com a nova data, ambiente e contagens efetivamente registradas. Usar CENARIOS_ETAPA1.md para transcrever os cenários. O PDF anterior não foi modificado nesta etapa.

## Próximas etapas, na ordem solicitada

10. Executar Docker Compose e preservar evidências reais. Docker não está disponível no ambiente desta alteração.
12. Preparar banco Oracle exclusivo para testes e validar a suíte, sem alterar a API. Definir se será Oracle local em contêiner ou uma instância de testes já existente. Não usar um banco de produção.
11. Vincular ao repositório https://github.com/danilo-chaves/fiap-esg-carbono-api, fixar o commit da API e executar o workflow. O workflow atual já aceita o repositório da API como entrada. A publicação e execução exigem acesso ao repositório de testes e aos Actions.

Nenhuma evidência de Docker, Oracle ou CI foi criada artificialmente.


## Atualização após execução pelo usuário

Logs recebidos confirmam a suíte local em 04/11/2026 01:00:21 -03:00 e Docker/H2 em 04/11/2026 01:22:12 -03:00, ambos com 34 cenários e 188 passos aprovados. A limitação de validação descrita acima corresponde ao ambiente de implementação, não ao resultado posterior do usuário. A configuração Oracle está documentada em ORACLE_DOCKER.md e ainda requer execução.
