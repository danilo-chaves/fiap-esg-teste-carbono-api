# Verificações da preparação Oracle

- Sintaxe Bash de run-oracle.sh e container-api-oracle.sh: aprovada com bash -n.
- Parse YAML e verificações de configuração: aprovados; três serviços, Flyway habilitado, baseline automático desabilitado, Hibernate sem criação de schema, nenhuma porta Oracle publicada no host.
- OracleBddBootstrap.java: compilação aprovada com Eclipse ECJ 3.42.0, linguagem/target Java 21, usando flyway-core 11.7.2 e spring-security-crypto 6.5.10 (mesmas versões identificadas no classpath da API recebida). Esse check compila o bootstrap, não a API inteira.
- Tratamento de falha do script: executado em diretório temporário com comando Docker simulado retornando 7; o script preservou diagnóstico e retornou 7. A simulação não produz evidência de banco nem de testes HTTP.
- Fontes e arquivos da API incluídos no pacote: comparação binária com a etapa 1 sem diferenças.
- Docker/Oracle: executado posteriormente pelo usuário com sucesso. Log final de 04/11/2026 02:14:59 -03:00: 34 cenários e 188 passos aprovados; Oracle encerrou completamente. Evidência em evidencias/oracle/logs-fornecidos/execucao-final-20261104-020618.log.
- Suíte: permanece com 34 cenários e 188 passos. Os resultados H2 anteriores não comprovam a execução Oracle.
