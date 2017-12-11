package sample.controller.appservice;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import org.springframework.stereotype.Service;
import sample.controller.entity.Candidate;

/**
 * @author gebara 2017/12/02.
 */
@Service
public class SampleAppService {

	private static List numberLists = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9);
	private static List stringLists = Arrays.asList("hoge",
			"fuge",
			"sample",
			"gebara"
	);

	public void samplerun() {
		List<Candidate> candidates = new ArrayList<>();
		for (int i = 0; i < 10; i++) {
			candidates.add(new Candidate(i, "hoge", true));
		}
		Stream<Candidate> stream = candidates.stream();
		List<Long> collect = candidates.stream()
				.map(Candidate::getId)
				.sorted(Long::compareTo)
				.collect(Collectors.toList());
		System.out.println(collect);
	}
}
