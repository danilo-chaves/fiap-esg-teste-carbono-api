package steps;
import io.cucumber.java.pt.*;
import io.restassured.response.Response;
import com.google.gson.Gson;
import java.time.LocalDate;
import java.math.BigDecimal;
import java.util.*;
import services.ApiService;
import static org.junit.Assert.*;
import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;

/** Cucumber cria esta classe novamente para cada cenário; nenhum estado global. */
public class CarbonoSteps {
 private final ApiService api=new ApiService();
 private final Map<String,String> vars=new HashMap<>();
 private Response response;
 private String token;
 private BigDecimal saldoInicial;
 public CarbonoSteps() {
  vars.put("adminEmail",ApiService.config("ADMIN_EMAIL","admin@teste.local"));
  vars.put("hoje",LocalDate.now().toString());
  vars.put("futuro",LocalDate.now().plusDays(30).toString());
  vars.put("futuroMaior",LocalDate.now().plusDays(60).toString());
  vars.put("ontem",LocalDate.now().minusDays(1).toString());
  vars.put("cnpj",cnpj());
 }
 private static String cnpj() {
  String n=String.format("%014d",new java.math.BigInteger(UUID.randomUUID().toString().replace("-", ""),16)
    .mod(new java.math.BigInteger("100000000000000")));
  return n.substring(0,2)+"."+n.substring(2,5)+"."+n.substring(5,8)+"/"+n.substring(8,12)+"-"+n.substring(12);
 }
 private String expand(String s) {
  for(var e:vars.entrySet()) s=s.replace("${"+e.getKey()+"}",e.getValue());
  if(s.contains("${")) throw new IllegalArgumentException("Variável não definida: "+s);
  return s;
 }
 private void check(int status,String schema) {
  response.then().statusCode(status).contentType("application/json").body(matchesJsonSchemaInClasspath("schemas/"+schema+".json"));
 }
 @Dado("que estou autenticado como {word}")
 public void login(String role) {
  String prefix=role.toUpperCase(Locale.ROOT);
  String email=ApiService.config(prefix+"_EMAIL",role.toLowerCase(Locale.ROOT)+"@teste.local");
  String password=ApiService.config(prefix+"_PASSWORD","Teste123!");
  response=api.request("POST","/auth/login",new Gson().toJson(Map.of("email",email,"senha",password)),null);
  check(200,"login");
  assertEquals(prefix,response.jsonPath().getString("role"));
  assertEquals(email,response.jsonPath().getString("email"));
  token=response.jsonPath().getString("token");
  assertNotNull("JWT obrigatório",token);
  assertFalse("JWT vazio",token.isBlank());
 }
 @Dado("que estou sem autenticação") public void anonymous() { token=null; }
 @Dado("que possuo uma empresa exclusiva")
 public void empresa() {
  login("ADMIN");
  criarEmpresa();
 }
 private void criarEmpresa() {
  requestBody("POST","/empresas-sustentaveis","{\"nome\":\"Empresa BDD\",\"cnpj\":\"${cnpj}\",\"setor\":\"Tecnologia\",\"pais\":\"Brasil\"}");
  check(201,"empresa"); save("id","empresaId");
 }
 @Dado("que possuo um agendamento exclusivo")
 public void agendamento() {
  empresa();
  criarAgendamento();
 }
 private void criarAgendamento() {
  requestBody("POST","/agendamento-reducao-carbono","{\"empresaId\":${empresaId},\"titulo\":\"Eficiência energética\",\"metaReducaoTco2e\":25,\"dataInicio\":\"${hoje}\",\"dataFimPrevista\":\"${futuro}\"}");
  check(201,"agendamento"); save("id","agendamentoId");
 }
 @Quando("cadastro uma empresa exclusiva") public void cadastrarEmpresa() { criarEmpresa(); }
 @Quando("cadastro um agendamento exclusivo") public void cadastrarAgendamento() { criarAgendamento(); }
 @Quando("registro uma emissão de {double} tCO2e") public void registrarEmissao(double n) { emissao(n); }
 @Quando("registro uma compensação de {double} tCO2e") public void registrarCompensacao(double n) { compensacao(n); }
 @Dado("que o agendamento está cancelado") public void cancelado() {
  request("DELETE","/agendamento-reducao-carbono/${agendamentoId}");
  status(204); empty();
 }
 @Quando("envio {word} para {string}")
 public void request(String method,String path) { response=api.request(method,expand(path),null,token); }
 @Quando("envio {word} para {string} com o JSON:")
 public void requestBody(String method,String path,String body) { response=api.request(method,expand(path),expand(body),token); }
 @Então("o status deve ser {int}") public void status(int status) { response.then().statusCode(status); }
 @Então("a resposta deve respeitar o contrato {string}") public void schema(String schema) {
  response.then().contentType("application/json").body(matchesJsonSchemaInClasspath("schemas/"+schema+".json"));
 }
 @Então("o campo {string} deve ser {string}") public void field(String path,String expected) {
  Object value=response.jsonPath().get(path); assertNotNull(path,value); assertEquals(expand(expected),String.valueOf(value));
 }
 @Então("o campo {string} deve valer {double}") public void number(String path, double expected) {
  Number n=response.jsonPath().get(path); assertNotNull(path,n); assertEquals(expected,n.doubleValue(),0.00001);
 }
 @Então("guardo o campo {string} como {string}") public void save(String path,String name) {
  Object v=response.jsonPath().get(path); assertNotNull(path,v); vars.put(name,String.valueOf(v));
 }
 @Então("o corpo deve estar vazio") public void empty() { assertTrue(response.asString().isEmpty()); }
 @Então("o erro deve apontar o campo {string}") public void invalidField(String field) {
  assertTrue(response.jsonPath().getList("errosCampos.campo",String.class).contains(field));
 }
 @Então("a página deve conter o id salvo em {string}") public void containsId(String name) {
  List<Number> ids=response.jsonPath().getList("content.id");
  assertTrue("Registro não localizado na página",ids.stream().anyMatch(id->id.longValue()==Long.parseLong(vars.get(name))));
 }
 @Então("a página deve pertencer à empresa exclusiva") public void owner() {
  List<Number> ids=response.jsonPath().getList("content.empresaId");
  assertFalse("Histórico vazio",ids.isEmpty());
  assertTrue(ids.stream().allMatch(id->id.longValue()==Long.parseLong(vars.get("empresaId"))));
 }
 @Dado("que registrei uma emissão de {double} tCO2e") public void emissao(double n) {
  requestBody("POST","/relatorio-emissao","{\"empresaId\":${empresaId},\"quantidadeTco2e\":"+n+",\"escopo\":\"ESCOPO_1\",\"dataEmissao\":\"${hoje}\"}");
  check(201,"emissao"); save("id","emissaoId");
 }
 @Dado("que registrei uma compensação de {double} tCO2e") public void compensacao(double n) {
  requestBody("POST","/compensacao-carbono","{\"empresaId\":${empresaId},\"quantidadeTco2e\":"+n+",\"tipo\":\"REFLORESTAMENTO\",\"dataCompensacao\":\"${hoje}\"}");
  check(201,"compensacao"); save("id","compensacaoId");
 }
 @Dado("que capturei o saldo líquido inicial") public void baseline() {
  request("GET","/indicadores-sustentabilidade"); check(200,"indicadores");
  saldoInicial=new BigDecimal(response.jsonPath().getString("saldoLiquidoTco2e"));
 }
 @Então("o saldo líquido deve aumentar {double} tCO2e") public void delta(double n) {
  assertNotNull(saldoInicial);
  BigDecimal atual=new BigDecimal(response.jsonPath().getString("saldoLiquidoTco2e"));
  assertEquals(0,atual.subtract(saldoInicial).compareTo(BigDecimal.valueOf(n)));
 }
}
