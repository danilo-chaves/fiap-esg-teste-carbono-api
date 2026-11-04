package hook;
import io.cucumber.java.Before;
import io.cucumber.java.Scenario;
public class Hook {
 @Before public void inicio(Scenario scenario) {
  scenario.log("Execução HTTP real; credenciais e JWT não são anexados. Cenário: "+scenario.getName());
 }
}
