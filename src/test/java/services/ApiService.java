package services;
import io.restassured.RestAssured;
import io.restassured.response.Response;
import io.restassured.config.HttpClientConfig;
import io.restassured.config.RestAssuredConfig;
import io.restassured.specification.RequestSpecification;

/** Cliente HTTP externo: não importa classes nem acessa o banco da API. */
public class ApiService {
 public static String config(String key, String fallback) {
  return System.getProperty(key, System.getenv().getOrDefault(key, fallback));
 }
 public Response request(String method, String path, String json, String token) {
  RequestSpecification req=RestAssured.given()
   .baseUri(config("BASE_URL", "http://localhost:8080/api/v1"))
   .config(RestAssuredConfig.config().httpClient(HttpClientConfig.httpClientConfig()
    .setParam("http.connection.timeout",10000).setParam("http.socket.timeout",30000)))
   .accept("application/json");
  if(token!=null) req.header("Authorization", "Bearer "+token);
  if(json!=null) req.contentType("application/json").body(json);
  return req.request(method,path);
 }
}
