package sample.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @author gebara 2017/11/25.
 */
@RestController
@RequestMapping("/")
public class SampleController {
	@GetMapping
	public String sample() {
		return "sample";
	}
}
