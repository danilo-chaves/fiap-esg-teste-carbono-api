# Publicar o projeto e acompanhar o GitHub Actions

## 1. Qual pasta publicar

Use a pasta teste-carbono-api desta versão CI. Ela contém a etapa 1, o Oracle e o workflow atualizado. Publique o conteúdo dessa pasta na raiz de https://github.com/danilo-chaves/fiap-esg-teste-carbono-api.

Não publique a pasta pai nem a carbono-api junto. O workflow obtém a API separadamente em https://github.com/danilo-chaves/fiap-esg-carbono-api. A API é fixada no commit e2f28b435eb25c41dd882089d9bd3dc84cbff704, comparado com pom.xml e src/ da versão validada nos logs do grupo.

## 2. Primeiro envio, para repositório remoto vazio

Extraia o ZIP em uma nova pasta. Abra o Git Bash dentro de teste-carbono-api. Confirme que a listagem contém pom.xml e README.md, e depois execute um comando por vez:

```bash
git init
git branch -M main
git add .
git status
```

Confira os arquivos exibidos: devem incluir .github/workflows/testes.yml; não devem incluir target/, .env ou .idea/. As evidências preservadas e os arquivos de configuração fictícios fazem parte do projeto.

Continue:

```bash
git commit -m "Adiciona testes BDD e CI com Oracle"
git remote add origin https://github.com/danilo-chaves/fiap-esg-teste-carbono-api.git
git push -u origin main
```

Se o Git solicitar sua identificação antes do commit, configure seu próprio nome e email. Se solicitar autenticação no push, conclua o login do GitHub pelo fluxo oferecido pelo Git para Windows. Não compartilhe tokens.

Essas instruções se destinam a uma nova pasta local e a um repositório remoto ainda vazio. Se você já publicou commits ou receber erro de origin existente ou envio rejeitado, não use force-push: confira a situação antes de continuar para preservar o histórico.

O primeiro push já dispara o workflow. Um novo push na mesma referência pode cancelar a execução anterior ainda em andamento.

## 3. Acompanhar

1. Abra https://github.com/danilo-chaves/fiap-esg-teste-carbono-api/actions.
2. Selecione Testes BDD Carbono API - Oracle.
3. Abra a execução e o job BDD e contratos com Oracle real.
4. Aguarde Docker preparar imagens, banco, migrações, API e testes. O job tem limite de 45 minutos.
5. Confira BUILD SUCCESS e o resumo de 34 cenários e 188 passos aprovados. O job verde comprova aprovação; ter apenas um workflow no repositório não comprova execução.
6. Baixe o artifact evidencias-oracle-<run_id>-<tentativa>. Ele preserva os relatórios atuais e diagnóstico, inclusive quando a execução falha. Não inclui automaticamente evidências históricas do repositório.

O resumo só é publicado se a conferência do JSON aprovar. A verificação exige também todos os passos e hooks aprovados. Ao modificar a suíte no futuro, revisar as contagens esperadas em scripts/check-cucumber-report.py e na documentação.

## 4. Eventos e ligação entre projetos

Pushes no repositório de testes disparam a suíte. Pull requests para main e workflow_dispatch também são aceitos. Um push feito somente no repositório da API não dispara o projeto de testes. Não é necessário modificar a API para o vínculo funcionar.

O acionamento manual permite informar outro commit, tag ou branch da API. Uma nova referência muda a versão testada. O commit efetivo de ambos os projetos fica em ci/ambiente.txt no artifact. A referência padrão está em API_REF no workflow.

O runner usa Docker e Java 21/Maven dentro das imagens existentes. O banco é novo e exclusivo de cada execução. Não há acesso a banco de produção. O volume de teste é removido no encerramento do job. As credenciais padrão são fictícias, conforme Compose.

O workflow tem permissão contents: read, sem commits, releases ou publicação da API. API_READ_TOKEN é opcional e se aplica a uma API privada que o token padrão do repositório de testes não consiga ler. PRs de forks não recebem secrets privados automaticamente.

## 5. Evidências para o PDF

Depois de confirmar o job aprovado, guardar:

- URL e identificador da execução, data/hora e commits testados.
- Print da execução aprovada e do resumo com as contagens.
- Print do log Oracle/migrações e do relatório Cucumber.
- Artifact completo baixado, preservado com identificação da execução.

Ainda não há resultado de CI confirmado nesta entrega. Os logs locais e Docker do grupo não devem ser apresentados como execução GitHub Actions.

## Referências

- https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax
- https://docs.github.com/en/actions/tutorials/store-and-share-data
- https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github
