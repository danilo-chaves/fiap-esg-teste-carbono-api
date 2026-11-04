import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
public class SeedGenerator {
 public static void main(String[] args) {
  String hash=new BCryptPasswordEncoder().encode("Teste123!");
  for(String role:new String[]{"ADMIN","EMPRESA","AUDITOR"})
   System.out.printf("INSERT INTO TB_USUARIO (NOME,EMAIL,SENHA,ROLE,ATIVO,DATA_CADASTRO) VALUES ('BDD %s','%s@teste.local','%s','%s',1,CURRENT_TIMESTAMP);%n",role,role.toLowerCase(java.util.Locale.ROOT),hash,role);
 }
}
