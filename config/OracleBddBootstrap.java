import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.util.Locale;
import org.flywaydb.core.Flyway;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

/** Preparação externa exclusiva do Oracle local BDD; não pertence à API nem à suíte HTTP. */
public class OracleBddBootstrap {
 private static final String URL = "jdbc:oracle:thin:@//oracle:1521/FREEPDB1";
 private static final String USER = "CARBONO_BDD";
 public static void main(String[] args) throws Exception {
  String password = System.getenv("BDD_ORACLE_PASSWORD");
  if (password == null || password.isBlank()) {
   throw new IllegalStateException("BDD_ORACLE_PASSWORD obrigatório");
  }
  try (Connection connection = DriverManager.getConnection(URL, USER, password)) {
   var metadata = connection.getMetaData();
   if (!metadata.getDatabaseProductName().toLowerCase(Locale.ROOT).contains("oracle")
       || !USER.equalsIgnoreCase(connection.getSchema())) {
    throw new IllegalStateException("Preparação permitida apenas no schema CARBONO_BDD do Oracle");
   }
   System.out.println("BDD DATABASE: " + metadata.getDatabaseProductName());
   System.out.println("BDD DATABASE VERSION: " + metadata.getDatabaseProductVersion());
   System.out.println("BDD SCHEMA: " + USER);
  }
  // Usa exatamente os recursos V1...V6 compilados a partir dos fontes originais.
  Flyway flyway = Flyway.configure().dataSource(URL, USER, password)
      .locations("classpath:db/migration").baselineOnMigrate(false).cleanDisabled(true).load();
  flyway.migrate();
  flyway.validate();
  for (var migration : flyway.info().applied()) {
   System.out.println("BDD MIGRATION: " + migration.getVersion() + " | "
       + migration.getDescription() + " | " + migration.getState());
  }
  // A API não fornece cadastro de usuários. MERGE torna a carga repetível sem mudar V6.
  String sql = """
      MERGE INTO TB_USUARIO t
      USING (SELECT ? NOME, ? EMAIL, ? SENHA, ? ROLE FROM DUAL) s
      ON (t.EMAIL = s.EMAIL)
      WHEN MATCHED THEN UPDATE SET t.NOME=s.NOME, t.SENHA=s.SENHA,
        t.ROLE=s.ROLE, t.ATIVO=1
      WHEN NOT MATCHED THEN INSERT (NOME,EMAIL,SENHA,ROLE,ATIVO,DATA_CADASTRO)
        VALUES (s.NOME,s.EMAIL,s.SENHA,s.ROLE,1,CURRENT_TIMESTAMP)
      """;
  String hash = new BCryptPasswordEncoder().encode("Teste123!");
  try (Connection connection = DriverManager.getConnection(URL, USER, password)) {
   connection.setAutoCommit(false);
   try (PreparedStatement statement = connection.prepareStatement(sql)) {
    for (String role : new String[]{"ADMIN", "EMPRESA", "AUDITOR"}) {
     statement.setString(1, "BDD " + role);
     statement.setString(2, role.toLowerCase(Locale.ROOT) + "@teste.local");
     statement.setString(3, hash);
     statement.setString(4, role);
     statement.executeUpdate();
    }
    connection.commit();
   } catch (Exception failure) {
    connection.rollback();
    throw failure;
   }
  }
  System.out.println("BDD USERS: 3 usuários fictícios preparados; credenciais não registradas");
 }
}
