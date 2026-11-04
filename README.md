# teste-carbono-api

Este projeto executa testes automatizados na Carbono API, uma aplicação de gestão de empresas, emissões, compensações e metas de redução de carbono.

Os testes enviam requisições HTTP para a API real e conferem as respostas. O projeto de testes possui seu próprio `pom.xml` e não altera os fontes da aplicação.

**Para começar no Windows, siga a opção A: Docker com Oracle.** Nesse modo, o Docker prepara o banco, inicia a API e executa os testes. Você não precisa instalar Java ou Maven no computador.

## 1. O que está incluído

- 34 cenários executáveis em Gherkin: 30 cenários e dois esquemas com dois exemplos cada.
- 17 cenários positivos e 17 negativos, distribuídos em seis funcionalidades.
- Cobertura das 15 operações HTTP da API.
- Conferência de status HTTP, campos JSON, cálculos e regras de negócio.
- 12 contratos JSON Schema.
- Execução com Oracle no Docker, H2 no Docker ou H2 local.
- Relatórios em HTML, JSON e XML.

BDD descreve o comportamento esperado usando passos como `Dado`, `Quando` e `Então`. Um cenário negativo aprovado significa que o sistema rejeitou corretamente uma entrada ou operação inválida.

## 2. Preparar as pastas

O material de entrega contém duas pastas. Extraia o ZIP antes de executar qualquer comando e mantenha ambas no mesmo diretório:

```text
atividade/
  carbono-api/
    pom.xml
    src/
  teste-carbono-api/
    README.md
    pom.xml
    compose.oracle.yaml
    scripts/
    config/
    src/
```

A pasta `carbono-api` contém a aplicação. A pasta `teste-carbono-api` contém os testes e os arquivos que preparam o ambiente.

**Todos os comandos deste README, salvo indicação contrária, devem ser executados dentro de `teste-carbono-api`.** No Windows, abra o Git Bash nessa pasta. Para conferir a localização, execute:

```bash
pwd
ls
```

A listagem deve mostrar `pom.xml`, `scripts` e `compose.oracle.yaml`. Não execute os comandos dentro do ZIP, da pasta `scripts` ou da pasta `carbono-api`.

### Se você recebeu somente o repositório de testes

Obtenha também a API original em https://github.com/danilo-chaves/fiap-esg-carbono-api. Extraia ou clone a API em uma pasta chamada `carbono-api`, ao lado de `teste-carbono-api`. Os scripts usam os fontes disponíveis nessa pasta; o comportamento pode mudar se você usar uma revisão diferente da API.

## 3. Opção A — Docker com Oracle

### Passo 1: instalar e abrir os programas

Instale, caso ainda não tenha:

- [Docker Desktop para Windows](https://docs.docker.com/desktop/setup/install/windows-install/).
- [Git para Windows](https://git-scm.com/downloads/win), que inclui o Git Bash.

Abra o Docker Desktop e aguarde a inicialização. É necessário acesso à internet para baixar as imagens e dependências. O primeiro download do Oracle pode demorar e requer espaço livre no disco.

### Passo 2: conferir o modo Linux

No Git Bash, execute:

```bash
docker info --format '{{.OSType}}'
docker compose version
```

O primeiro comando deve retornar `linux`; o segundo deve mostrar a versão do Compose. Se houver erro de conexão, aguarde o Docker Desktop ficar pronto.

Se retornar `windows`, clique com o botão direito no ícone da baleia, perto do relógio do Windows, e selecione **Switch to Linux containers**. Se aparecer **Switch to Windows containers**, o modo Linux já está ativo.

### Passo 3: executar

Dentro de `teste-carbono-api`, execute:

```bash
bash scripts/run-oracle.sh
```

Não é necessário iniciar a API no IntelliJ. O script e o Docker fazem a preparação completa:

1. Baixam as imagens e compilam os projetos.
2. Iniciam o banco Oracle e aguardam sua disponibilidade.
3. Aplicam e validam as migrações originais V1 a V6.
4. Preparam os usuários fictícios da suíte.
5. Iniciam a API com uma configuração externa de testes.
6. Executam os 34 cenários por HTTP.
7. Encerram os serviços e preservam as evidências da tentativa.

Não interrompa o comando enquanto o banco estiver inicializando. Durante a execução, a API usa `http://localhost:8081/api/v1`. O banco não publica uma porta no Windows.

### Passo 4: reconhecer o resultado

Uma execução completa aprovada apresenta:

```text
34 Scenarios (34 passed)
188 Steps (188 passed)
Tests run: 34, Failures: 0, Errors: 0, Skipped: 0
BUILD SUCCESS
tests-1 exited with code 0
```

No log da API, confira também `BDD DATABASE: Oracle`, `BDD SCHEMA: CARBONO_BDD` e as seis linhas `BDD MIGRATION`, com resultado `SUCCESS`.

Depois da primeira execução, a mensagem `Schema ... is up to date. No migration necessary.` é esperada: as migrações já estão aplicadas no volume. O bootstrap prepara novamente os usuários sem duplicá-los.

Avisos de validação, recurso inexistente e acesso negado podem fazer parte dos cenários negativos. O healthcheck também envia login vazio e pode gerar avisos de campos obrigatórios. Avalie o resumo final dos testes; não considere qualquer linha WARN como falha da suíte.

### Passo 5: abrir os relatórios

O script informa o caminho das evidências. No Explorador de Arquivos, abra:

```text
evidencias/oracle/<data-hora>/cucumber-reports.html
```

Substitua `<data-hora>` pela pasta criada na sua execução. Abra o HTML no navegador e expanda as funcionalidades e os cenários.

Na mesma pasta ficam os relatórios JSON/XML, o resultado Surefire quando gerado, o log da execução, o log da API e o diagnóstico dos contêineres. Tentativas que falham antes dos testes podem não produzir relatórios Cucumber.

Os relatórios mais recentes desse modo também ficam em `target/oracle/`. Use a cópia em `evidencias/` para documentar a entrega, porque novas execuções atualizam os arquivos de `target/`.

### Passo 6: remover os contêineres

Após consultar os resultados:

```bash
docker compose -f compose.oracle.yaml down
```

Isso remove os contêineres e a rede, mantendo o volume do banco. Os testes criam registros fictícios; novas execuções podem acumular esses registros.

O Oracle possui `stop_grace_period: 2m` para dar tempo ao desligamento. Na validação final, o log registrou `Instance shutdown complete`. O código 143 após essa mensagem e a parada solicitada pelo Compose não representa falha dos testes. Os testes devem terminar com código 0.

**Somente se você quiser apagar todos os dados desse banco de testes e executar as migrações novamente**, use:

```bash
docker compose -f compose.oracle.yaml down --volumes
```

Esse comando apaga o volume Oracle exclusivo deste projeto. Não é necessário usá-lo ao terminar cada execução.

## 4. Opção B — Docker com H2

H2 é um banco em memória. Essa alternativa executa a API real, mas não comprova as migrações Oracle. Requer o mesmo Docker Desktop em modo Linux.

Dentro de `teste-carbono-api`, execute:

```bash
docker compose up --build --abort-on-container-exit --exit-code-from tests
```

A porta 8080 deve estar livre. O banco H2 é descartado ao encerrar a API. Os relatórios ficam diretamente em `target/`, incluindo `target/cucumber-reports.html`.

Depois de preservar os relatórios e prints:

```bash
docker compose down
```

Esse modo usa `compose.yaml`. O modo Oracle usa `compose.oracle.yaml`. Execute cada comando exatamente como indicado; os arquivos não precisam ser combinados.

## 5. Opção C — H2 local, sem Docker

Instale **JDK 21**, **Maven 3.9 ou superior** e Git Bash. Tenha `curl` disponível e acesso à internet para as dependências. Confira:

```bash
java -version
javac -version
mvn -version
curl --version
```

`java`, `javac` e o Java indicado por `mvn -version` devem usar a versão 21. A porta 8080 deve estar livre. Dentro de `teste-carbono-api`, execute:

```bash
bash scripts/run-local.sh
```

O script compila e inicia a API, executa os testes e encerra o processo ao terminar. A inicialização pode aguardar aproximadamente 30 minutos em uma primeira compilação demorada. O log da API fica em `target/api.log`, e os relatórios ficam diretamente em `target/`.

Esse modo usa H2 em modo de compatibilidade Oracle, `create-drop` e Flyway desabilitado. O H2 não equivale ao banco Oracle real. Somente arquivos gerados em `target/` são adicionados à pasta original da API durante a compilação.

Para a API em outro caminho, use aspas quando houver espaços:

```bash
CARBONO_API_DIR="/c/caminho/com espacos/carbono-api" bash scripts/run-local.sh
```

## 6. Usar o IntelliJ

Abra a pasta `teste-carbono-api` no IntelliJ como projeto Maven. Para as opções Docker, não é necessário executar classes Java pela IDE: use os comandos anteriores no Git Bash.

Para a opção local, configure o JDK 21 no projeto e no Maven. O terminal pode usar um Java diferente da configuração da IDE; confira com `mvn -version`.

Executar somente `TestRunner` ou `mvn test` não inicia a API. Para a execução completa, use `run-local.sh`, `run-oracle.sh` ou o Compose conforme a opção escolhida.

## 7. Executar somente os testes contra uma API já iniciada

Essa é uma opção avançada. A API deve estar acessível, possuir usuários ADMIN e AUDITOR conhecidos e aceitar os dados fictícios criados pela suíte. Use um ambiente exclusivo de testes, sem alterações concorrentes.

No Git Bash:

```bash
export BASE_URL=http://localhost:8080/api/v1
export ADMIN_EMAIL=admin@teste.local
export ADMIN_PASSWORD='Teste123!'
export AUDITOR_EMAIL=auditor@teste.local
export AUDITOR_PASSWORD='Teste123!'
mvn -B test
```

Os endereços e as credenciais acima são exemplos do ambiente preparado pelos scripts. No modo Oracle do Compose, a API encerra com os testes; use o fluxo completo da opção A para preparar e executar tudo.

No PowerShell, configure as variáveis com `$env:NOME_DA_VARIAVEL = 'valor'` e execute `./scripts/test.ps1`. Esse script também exige que a API já esteja iniciada.

Os scripts Bash e PowerShell não carregam `.env` automaticamente. O Compose usa `.env` para seus próprios parâmetros. Não é necessário criar `.env` para a execução padrão.

## 8. Selecionar cenários por tags

Tags são marcadores que permitem executar parte da suíte:

| Tag | Seleção |
|---|---|
| `@regressivo` | Todos os cenários atuais |
| `@positivo` | Operações válidas |
| `@negativo` | Rejeições e restrições esperadas |
| `@contrato` | Cenários marcados com validação de contrato, incluindo a preparação |
| `@governanca` | Autenticação e controle de acesso |
| `@esg` | Empresas, emissões, planos, compensações e indicadores |

Na execução local completa:

```bash
bash scripts/run-local.sh '-Dcucumber.filter.tags=@negativo'
bash scripts/run-local.sh '-Dcucumber.filter.tags=@positivo and @esg'
```

Com uma API já iniciada:

```bash
mvn test '-Dcucumber.filter.tags=@governanca'
```

A contagem será menor ao usar filtros. `run-oracle.sh` executa a suíte completa; não possui parâmetro para filtros.

Para verificar somente a ligação dos passos sem chamar a API:

```bash
mvn test -Dcucumber.execution.dry-run=true
```

Esse comando não comprova o funcionamento da aplicação.

## 9. Problemas comuns

| Sintoma | O que conferir |
|---|---|
| `docker: command not found` | Instalação do Docker e abertura de um novo terminal após instalar |
| Falha ao conectar ao Docker | Docker Desktop aberto e inicialização concluída |
| `no matching manifest` | Modo Linux e compatibilidade da imagem com a arquitetura do computador |
| `No such file or directory` | Pasta atual e existência da pasta irmã `carbono-api` |
| Porta ocupada | Encerrar o serviço conflitante ou usar outra porta Oracle, conforme exemplo abaixo |
| `mvn` ou `javac` não encontrado | Para opção local, instalar Maven/JDK e ajustar PATH; no Docker isso não é necessário |
| Erro de login nos testes | Preparação dos usuários e possíveis variáveis ADMIN/AUDITOR antigas no terminal |
| Migração falhou ou mensagem `ORA-...` | Consultar o log da API e do Oracle; enviar o erro completo para análise |
| `BUILD FAILURE` | Abrir Surefire e o primeiro erro de teste, não apenas a última linha do log |
| Arquivos com acentos diferentes no terminal | Conferir o relatório HTML e a codificação do terminal; não editar as features apenas pela aparência do console |

Para mudar a porta HTTP do modo Oracle, antes de executar:

```bash
export BDD_ORACLE_HTTP_PORT=8082
bash scripts/run-oracle.sh
```

Para consultar os serviços Oracle:

```bash
docker compose -f compose.oracle.yaml ps -a
docker compose -f compose.oracle.yaml logs --no-color api
docker compose -f compose.oracle.yaml logs --no-color oracle
```

Não troque as senhas do banco no ambiente ao reutilizar um volume existente: isso não redefine automaticamente as senhas dos usuários já criados. O guia técnico explica os parâmetros opcionais.

## 10. Resultados já confirmados

Execuções fornecidas pelo responsável pelo projeto, em horário de São Paulo:

| Modo | Conclusão dos testes | Resultado |
|---|---|---|
| H2 local | 04/11/2026 01:00:21 | 34 cenários, 188 passos, zero falhas/erros/ignorados |
| H2 no Docker | 04/11/2026 01:22:12 | 34 cenários, 188 passos, zero falhas/erros/ignorados |
| Oracle no Docker | 04/11/2026 02:14:59 | 34 cenários, 188 passos, zero falhas/erros/ignorados |

Oracle identificado no log: **Oracle AI Database 26ai Free, release 23.26.3.0.0**, schema `CARBONO_BDD`. A primeira execução aplicou V1 a V6; a execução final confirmou o schema atualizado e o desligamento completo do banco.

Os logs fornecidos estão em `evidencias/etapa1/`, `evidencias/docker/` e `evidencias/oracle/logs-fornecidos/`. Os relatórios HTML/JSON/XML de 30/10 ficam em `evidencias/historico-2026-10-30/` e correspondem à versão anterior de 25 cenários. Eles não comprovam os 34 cenários atuais. As cópias dos relatórios completos das execuções recentes devem ser preservadas no computador em que os testes foram realizados ou trazidas para o pacote final.

## 11. GitHub e integração contínua

Repositórios:

- Testes: https://github.com/danilo-chaves/fiap-esg-teste-carbono-api
- API: https://github.com/danilo-chaves/fiap-esg-carbono-api

O conteúdo desta pasta deve ficar diretamente na raiz do repositório de testes: `pom.xml`, `README.md`, `src/`, `scripts/`, `config/`, `docs/`, `evidencias/`, Dockerfiles, Compose e `.github/`. A API permanece no repositório próprio.

O workflow `.github/workflows/testes.yml` está configurado para:

1. Iniciar em pushes, pull requests para `main` ou acionamento manual.
2. Obter os testes e a API em pastas separadas, sem alterar o repositório da API.
3. Usar o commit da API `e2f28b435eb25c41dd882089d9bd3dc84cbff704`, cujo `pom.xml` e `src/` foram comparados e correspondem aos arquivos da API incluída no pacote validado pelo grupo.
4. Iniciar Oracle e API pelo Docker e executar os 34 cenários completos.
5. Conferir o JSON para exigir 34 cenários e 188 passos aprovados; falhas, passos ignorados, relatório ausente ou contagens diferentes reprovam o job.
6. Registrar commits e ambiente, preservar relatórios/logs como artifacts por 30 dias e remover os contêineres e o volume de testes do runner.

A execução ocorre em um runner Ubuntu do GitHub. Não depende do Docker Desktop, Java, Maven ou Oracle do seu computador. Um push somente no repositório da API não dispara este workflow; a referência da API é fixa para manter a reprodução.

### Publicar pela primeira vez

Veja o passo a passo em [Publicação e CI](docs/GITHUB_ACTIONS.md). O `.gitignore` exclui `target/`, `.env` e arquivos locais da IDE. A pasta `.github/` deve ser incluída.

### Consultar uma execução

No repositório de testes, abra **Actions → Testes BDD Carbono API - Oracle**. Clique na execução e acompanhe o job **BDD e contratos com Oracle real**. Um resultado aprovado deve mostrar o job verde, BUILD SUCCESS e o resumo com 34 cenários e 188 passos aprovados.

Na página da execução, baixe `evidencias-oracle-<run_id>-<tentativa>` na seção **Artifacts**. O relatório HTML fica dentro da pasta `oracle` do arquivo baixado. Os logs e commits ficam em `ci/`. A disponibilidade dos arquivos depende do ponto em que a execução chegou: uma falha ao iniciar o banco pode não gerar Cucumber.

Para iniciar manualmente, abra **Run workflow**, selecione `main` e deixe `api_ref` vazio para usar o commit validado. A opção manual aparece depois que o workflow estiver publicado na branch padrão. Só informe outra referência se quiser testar uma versão diferente da API.

Se a API estiver privada, o checkout poderá exigir um secret `API_READ_TOKEN` com acesso de leitura ao repositório da API. Não coloque tokens no código ou no README. Não é necessário criar esse secret para obter uma API pública.

**Estado da validação:** o workflow foi preparado e verificado estaticamente; a execução real no GitHub ainda precisa ocorrer após a publicação. Não há evidência de aprovação do CI nesta versão. Os resultados locais/Docker anteriores continuam documentados na seção 10.

## 12. Organização técnica e limites

Tecnologias: Java 21, Maven, Cucumber 7.18.1, JUnit 4 e REST Assured 5.5.0. A API utiliza Spring Boot 3.5.14.

| Pasta | Conteúdo |
|---|---|
| `src/main/resources/features/` | Comportamentos e exemplos em Gherkin |
| `src/main/resources/schemas/` | Contratos JSON Schema Draft 4 |
| `src/test/java/runner/` | Execução Cucumber/JUnit |
| `src/test/java/steps/` | Preparação e verificações dos passos |
| `src/test/java/services/` | Cliente HTTP |
| `src/test/java/hook/` | Registro do início dos cenários |
| `config/` | Preparação externa do ambiente de testes |
| `scripts/` | Comandos de execução |
| `docs/` | Matriz e detalhes técnicos |
| `evidencias/` | Logs e relatórios preservados |

A API não oferece cadastro de usuários; por isso os scripts preparam ADMIN, EMPRESA e AUDITOR externamente, com BCrypt. O cliente de testes não acessa diretamente o banco. Usuários HTTP fictícios usam senha `Teste123!`; os testes atuais exercitam ADMIN, AUDITOR e acesso anônimo.

No Oracle, Flyway aplica os scripts originais e Hibernate não cria tabelas. No H2, Hibernate cria tabelas temporárias e Flyway fica desabilitado. Não use essas configurações de testes em produção.

Os cenários criam dados próprios, guardam IDs e usam datas relativas. O CNPJ gerado é fictício e atende ao formato validado pela API; não representa cadastro fiscal real. Execute sequencialmente e sem escritores concorrentes. Listagens procuram registros entre os 100 mais recentes; o saldo é validado pela diferença antes/depois.

DELETE de agendamento representa cancelamento lógico. Respostas 204 são verificadas como corpo vazio e não recebem JSON Schema. Os bloqueios 403 do filtro de segurança validam status, pois não há contrato garantido para o corpo; as demais respostas JSON verificadas possuem schemas.

Os testes apoiam a integridade ambiental dos registros e a governança de acesso. Não certificam conformidade legal, acessibilidade, diversidade ou redução real de carbono. Cobrir todas as operações HTTP não significa cobrir todas as linhas ou combinações possíveis.

Detalhes:

- [Matriz de cobertura](docs/MATRIZ_COBERTURA.md)
- [Guia técnico Oracle](docs/ORACLE_DOCKER.md)
- [Cenários atuais para documentação](docs/CENARIOS_ETAPA1.md)
