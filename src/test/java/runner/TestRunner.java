package runner;
import org.junit.runner.RunWith;
import io.cucumber.junit.Cucumber;
import io.cucumber.junit.CucumberOptions;
@RunWith(Cucumber.class)
@CucumberOptions(features="classpath:features", glue={"steps", "hook"},
 plugin={"pretty", "summary", "html:target/cucumber-reports.html", "json:target/cucumber.json", "junit:target/cucumber.xml"})
public class TestRunner { }
