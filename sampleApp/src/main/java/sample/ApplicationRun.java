package sample;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * @author gebara 2017/11/25.
 */
@Configuration
@ComponentScan
@SpringBootApplication(scanBasePackages = "sample")
public class ApplicationRun {
	public static void main(String[] args) {
		SpringApplication.run(ApplicationRun.class, args);
	}
}
