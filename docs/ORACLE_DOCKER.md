# Oracle Docker — execução da suíte BDD

## Estado atual

Suíte com 34 cenários e 188 passos, aprovada em execução local/H2 e Docker/H2 conforme logs fornecidos em 04/11/2026. A execução Oracle foi confirmada pelos logs fornecidos em 04/11/2026: 34 cenários e 188 passos aprovados, zero falhas, erros e ignorados. Migrações V1 a V6 com SUCCESS. A execução final, às 02:14:59 -03:00, confirmou o desligamento completo após stop_grace_period: 2m. CI ainda não foi executado.

## Executar no Windows com Git Bash

1. Extraia as pastas carbono-api e teste-carbono-api lado a lado.
2. Abra o Docker Desktop, usando contêineres Linux. Garanta recursos livres para Oracle, API e Maven; consulte os requisitos da imagem abaixo.
3. Entre em teste-carbono-api e execute:

```bash
bash scripts/run-oracle.sh
```

JDK e Maven do host não são necessários neste modo: o build usa as imagens Java 21/Maven. A primeira execução baixa a imagem Oracle e as dependências. Não interrompa enquanto o banco estiver inicializando. O healthcheck do Oracle aguarda até aproximadamente 16 minutos após o download; o da API aguarda mais aproximadamente 10 minutos.

## Fluxo

- Imagem gvenzl/oracle-free:23.26.3-slim-faststart (imagem mantida pelo projeto gvenzl, executando Oracle real).
- Serviço Oracle FREEPDB1; schema exclusivo CARBONO_BDD. Porta do banco acessível somente na rede Compose.
- Dockerfile.api compila a API original sem alterar pom ou fontes.
- Bootstrap externo confirma produto Oracle e schema CARBONO_BDD, aplica V1...V6 com Flyway, valida checksums e prepara três usuários fictícios usando MERGE e BCrypt.
- A classe principal original é iniciada com application-bdd-oracle.yaml: Oracle, Flyway habilitado, baseline automático desabilitado, clean desabilitado, Hibernate ddl-auto none, carga SQL Spring desabilitada.
- Após healthcheck, REST Assured executa os mesmos cenários por HTTP.

O acesso JDBC é restrito à preparação do ambiente; a suíte de testes continua independente e exclusivamente HTTP. Não se depende da senha documentada no seed V6. O seed original permanece intacto e é executado por Flyway.

## Resultado e evidências

Ao terminar, verificar BUILD SUCCESS, 34 cenários e 188 passos aprovados, zero falhas/erros/ignorados e código de saída zero do contêiner tests. Confirmar também no api-oracle.log as linhas BDD DATABASE, BDD DATABASE VERSION, BDD SCHEMA e BDD MIGRATION.

Os relatórios ficam em target/oracle/. O script copia relatórios existentes e diagnóstico para evidencias/oracle/<data-hora>/. Relatórios anteriores ao startup são separados em relatorios-anteriores e não comprovam a tentativa atual. O script retorna falha se Compose falhar ou terminar sem cucumber.xml.

Para capturar prints, abrir o HTML preservado no navegador e registrar o resumo Maven e as linhas do banco/migrações. Incluir no PDF versão real do Oracle, data, ambiente, contagens e resultado. Não substituir os resultados anteriores antes de confirmar a nova execução.

## Parâmetros opcionais

Para mudar porta ou imagem, exportar a variável no Git Bash antes de executar, ou colocar no .env local do projeto de testes (não versionar):

```bash
export BDD_ORACLE_HTTP_PORT=8082
bash scripts/run-oracle.sh
```

BDD_ORACLE_IMAGE altera a imagem (padrão versionado acima). BDD_ORACLE_ADMIN_PASSWORD e BDD_ORACLE_PASSWORD alteram senhas locais do banco. Usar as mesmas senhas ao reutilizar o volume; mudanças no ambiente não redefinem usuários de um banco já inicializado. Não enviar senhas reais. O modo padrão usa somente valores fictícios explícitos.

## Diagnóstico e encerramento

```bash
docker compose -f compose.oracle.yaml ps -a
docker compose -f compose.oracle.yaml logs --no-color oracle
docker compose -f compose.oracle.yaml logs --no-color api
docker compose -f compose.oracle.yaml down
```

Warnings de rejeições de negócio são esperados em testes negativos. Erros ORA, falhas Flyway ou de login devem ser analisados e não marcados como sucesso. Se a porta 8081 estiver ocupada, usar BDD_ORACLE_HTTP_PORT.

O volume mantém somente os dados deste Oracle BDD. Para repetir as migrações em um banco vazio, o comando abaixo APAGA o volume e todos os seus dados de teste:

```bash
docker compose -f compose.oracle.yaml down --volumes
bash scripts/run-oracle.sh
```

Nenhum comando aponta para o Oracle da aplicação original ou para uma instância remota.

## Referências primárias

- Imagem, APP_USER, FREEPDB1 e healthcheck: https://github.com/gvenzl/oci-oracle-free
- API Java de migração Flyway: https://documentation.red-gate.com/flyway/reference/usage/api-java

## Próxima etapa

Oracle já confirmado nos logs fornecidos. O workflow Oracle está preparado para o item 11; consultar GITHUB_ACTIONS.md. A execução real do CI ainda precisa ocorrer após publicar o projeto. Nenhum repositório remoto foi alterado durante a preparação deste pacote.
