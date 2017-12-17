package sample.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import sample.controller.appservice.SampleAppService;

/**
 * @author gebara 2017/11/25.
 */
@RestController
@RequestMapping("/")
public class SampleController {

	@Autowired
	private SampleAppService sampleAppService;
	@GetMapping
	public String sample() {
		sampleAppService.sampleRun();
		return "sample";
	}
}
