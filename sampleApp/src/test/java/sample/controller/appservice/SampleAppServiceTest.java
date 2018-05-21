package sample.controller.appservice;


import java.util.*;
import java.util.Map.Entry;
import java.util.function.Function;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import org.apache.commons.collections4.MapUtils;
import org.junit.Test;

/**
 * @author gebara 2017/12/17.
 */
public class SampleAppServiceTest {

	private Optional<String> stringOptional = null;

	/**
	 * 出力値は？
	 * 1 45
	 * 2 error
	 */
	@Test
	public void test_Stream_sum() {
		List<Integer> numberLists = Arrays.asList(1, 2, 3, 4, 5, 6, 7, 8, 9);
		int sum = numberLists.stream()
				.flatMapToInt(IntStream::of)
				.sum();
		System.out.println(sum);
	}

	/**
	 * 出力値は？
	 * 1 45
	 * 2 43
	 * 3 error
	 */
	@Test
	public void test_Stream_sum2() {
		List<Integer> numberLists = Arrays.asList(1, null, 3, 4, 5, 6, 7, 8, 9);
		int sum = numberLists.stream()
				.flatMapToInt(IntStream::of)
				.sum();
		System.out.println(sum);
	}

	/**
	 * 出力値は？
	 * 1 45
	 * 2 43
	 * 3 error
	 */
	@Test
	public void test_Stream_sum3() {
		List<Integer> numberLists = Arrays.asList(1, null, 3, 4, 5, 6, 7, 8, 9);
		int sum = numberLists.stream()
				.filter(Objects::nonNull)
				.flatMapToInt(IntStream::of)
				.sum();
		System.out.println(sum);
	}

	/**
	 * 出力値は？
	 * 1 45
	 * 2 43
	 * 3 51
	 * 4 error
	 */
	@Test
	public void test_Stream_sum4() {
		List<Integer> numberLists = Arrays.asList(1, null, 3, 4, 5, 6, 7, 8, 9);
		int sum = numberLists.stream()
				.filter(Objects::nonNull)
				.flatMapToInt(IntStream::of)
				.map(i -> i + 1)
				.sum();
		System.out.println(sum);
	}

	/**
	 * 出力値は？
	 * 1 [1, 1, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9]
	 * 2 [1, 3, 4, 5, 6, 7, 8, 9]
	 * 3 error
	 */
	@Test
	public void test_Stream_side_effect() {
		List<Integer> numberLists = Arrays.asList(1, null, 3, 4, 5, 6, 7, 8, 9);
		List<Integer> objects = new ArrayList<>();
		objects.add(1);
		objects.add(1);
		objects.add(1);
		objects.add(1);
		List<Integer> list = new ArrayList<>();
//		numberLists.add(1);
		objects.stream()
				.filter(Objects::nonNull)
				.filter(i -> {
					list.add(i);// こういう副作用をstreamの中で書かない。
					objects.add(i);
					return true;
				})
				.map(i -> {
					objects.remove(i); // こういう副作用をstreamの中で書かない。
					list.add(i); // こういう副作用をstreamの中で書かない。
					return i;
				})
				.flatMapToInt(IntStream::of)
				.sum();
		System.out.println(list);
	}

	/**
	 * 最終出力値は？
	 * 1 [1, 3, 4, 5, 6, 7, 8, 9]
	 * 2 [2, 4, 5, 6, 7, 8, 9, 10]
	 * 3 [3, 5, 6, 7, 8, 9, 10, 11]
	 * 4 error
	 */
	@Test
	public void test_Stream_peek() {
		List<Integer> numberLists = Arrays.asList(1, null, 3, 4, 5, 6, 7, 8, 9);
		List<Integer> collect = numberLists.stream()
				.filter(Objects::nonNull)
				.peek(System.out::println) // loggerなどデバッグのためにpeekを使う
				.map(integer -> integer + 1)
				.peek(integer -> System.out.println(integer + 1))
				.collect(Collectors.toList());
		System.out.println(collect);
	}

	/**
	 * 出力値は？
	 * 1 [hoge, fuge, sample, gebara, hoge, fuge, java8]
	 * 2 [hoge, fuge, sample, gebara, java8]
	 * 3 error
	 */
	@Test
	public void test_Stream_distinct() {
		List<String> items = Arrays.asList(
				"hoge", "fuge", "sample", "gebara",
				"hoge", "fuge", "java8"
		);
		List<String> result = items.stream()
				.distinct()
				.collect(Collectors.toList());
		System.out.println(result);
	}

	/**
	 * 出力値は？
	 * 1 {java8=java8, hoge=hogehoge, gebara=geabara, sample=sample, fuge=fugefuge}
	 * 2 {java8=1, hoge=2, gebara=1, sample=1, fuge=2}
	 * 3 {java8=1, gebara=1, sample=1, hoge=2, fuge=2}
	 * 4 {hoge=2, fuge=2, java8=1, gebara=1, sample=1}
	 * 5 error
	 */
	@Test
	public void test_Stream_sorted() {
		List<String> items = Arrays.asList(
				"hoge", "fuge", "sample", "gebara",
				"hoge", "fuge", "java8"
		);
		Map<String, Long> result = items.stream()
				.collect(Collectors.groupingBy(
						Function.identity(),
						Collectors.counting()
						)
				).entrySet().stream()
				.sorted(Entry.<String, Long>comparingByValue().reversed())
				.collect(Collectors.toMap(Entry::getKey, Entry::getValue));
		System.out.println(result);
	}

	/**
	 * 出力値は？
	 * 1 {java8=java8, hoge=hogehoge, gebara=geabara, sample=sample, fuge=fugefuge}
	 * 2 {java8=1, hoge=2, gebara=1, sample=1, fuge=2}
	 * 3 {java8=1, gebara=1, sample=1, hoge=2, fuge=2}
	 * 4 {hoge=2, fuge=2, java8=1, gebara=1, sample=1}
	 * 5 error
	 */
	@Test
	public void test_Stream_sorted2() {
		List<String> items = Arrays.asList(
				"hoge", "fuge", "sample", "gebara",
				"hoge", "fuge", "java8"
		);
		Map<String, Long> collect = items.stream()
				.collect(Collectors.groupingBy(
						Function.identity(),
						Collectors.counting()
						)
				).entrySet().stream()
				.sorted(Entry.<String, Long>comparingByValue().reversed())
				.collect(Collectors.toMap(Entry::getKey,
						Entry::getValue,
						(oldMap, newMap) -> oldMap,
						LinkedHashMap::new));
		System.out.println(collect);
	}

	/**
	 * 出力値は？
	 * 1 1
	 * 2 999
	 * 3 error
	 * 4 その他
	 */
	@Test
	public void test_Optional1() {
		Integer integer = Optional.ofNullable(1).orElse(testOrElse());
		System.out.println(integer);
	}

	/**
	 * 出力値は？
	 * 1 1
	 * 2 999
	 * 3 error
	 * 4 その他
	 */
	@Test
	public void test_Optional2() {
		Integer integer = Optional.ofNullable(1).orElseGet(this::testOrElse);
		System.out.println(integer);
	}

	private int testOrElse() {
		System.out.println("hoge----");
		return 999;
	}

	/**
	 * 出力値は？
	 * 1 Optional[3]
	 * 2 Optional.empty
	 * 3 error
	 */
	@Test
	public void test_Optional_flatMap() {
//		Optional<Integer> a = Optional.empty();
//		Optional<Integer> c = Optional.of(3);
//		Optional<Integer> result;
//		if (a.isPresent()) {
//			if (b.isPresent()) {
//				result = Optional.of(a.get() + b.get());
//			} else {
//				result = Optional.empty();
//			}
//		} else {
//			result = Optional.empty();
//		}
		Optional<Integer> a = Optional.empty();
		Optional<Integer> b = Optional.of(3);
		Optional<Integer> c = a.flatMap(x -> b.map(y -> x + y));
		System.out.println(c);
	}

	/**
	 * 出力値は？
	 * 1 test
	 * 2 null
	 * 3 error
	 */
	@Test
	public void test_Optional_field() {
		String s = stringOptional.orElse("test");
		System.out.println(s);
	}

	/**
	 * 出力値は？
	 * 1 test
	 * 2 null
	 * 3 error
	 */
	@Test
	public void test_Optional_Optional() {
		Optional<Optional<String>> optional = Optional.ofNullable(Optional.ofNullable("test"));

		String test = optional.flatMap(s -> s).orElse(null);
		System.out.println(test);
	}

	/**
	 * 出力値は？
	 * 1 ComputeIfAbsent put    -> [hoge]
	 * 	 ComputeIfAbsent no put -> null
	 * 2 ComputeIfAbsent put    -> [hoge]
	 * 	 ComputeIfAbsent no put -> [piyo]
	 * 3 error
	 */
	public void test_map_java8() {
		// get default
		Map<String, List<String>> mapCompute1 = new HashMap<>();
		Map<String, List<String>> mapCompute2 = new HashMap<>();

		mapCompute1.put("test", Arrays.asList("hoge"));

		List<String> res1 = mapCompute1.computeIfAbsent("test", key -> Arrays.asList("piyo"));
		List<String> res2 = mapCompute2.computeIfAbsent("test", key -> Arrays.asList("piyo"));

		System.out.println("ComputeIfAbsent put   -> " + res1);
		System.out.println("ComputeIfAbsent no put-> " + res2);
	}

	/**
	 * 出力値は？
	 * 1 GetOrDefault put    -> [hoge]
	 * 	 GetOrDefault no put -> null
	 * 2 GetOrDefault put    -> [hoge]
	 * 	 GetOrDefault no put -> [piyo]
	 * 3 error
	 */
	public void test_map_java8_2() {
		Map<String, List<String>> mapDefault1 = new HashMap<>();
		Map<String, List<String>> mapDefault2 = new HashMap<>();

		mapDefault1.put("test", Arrays.asList("hoge"));

		List<String> resD1 = mapDefault1.getOrDefault("test", Arrays.asList("piyo"));
		List<String> resD2 = mapDefault2.getOrDefault("test", Arrays.asList("piyo"));

		System.out.println("GetOrDefault put    -> " + resD1);
		System.out.println("GetOrDefault no put -> " + resD2);
	}

	/**
	 * 1 ComputeIfAbsent added -> [piyo, piyo]
	 *   GetOrDefault    added -> [piyo]
	 * 2 ComputeIfAbsent added -> [piyo, piyo]
	 *   GetOrDefault    added -> [piyo, piyo]
	 * 3 ComputeIfAbsent added -> [piyo, piyo]
	 *   GetOrDefault    added -> null
	 * 4 error
	 */
	public void test_map_java8_3() {
		Map<String, List<String>> mapComputeS = new HashMap<>();
		Map<String, List<String>> mapDefaultS = new HashMap<>();

		List<String> resCS = mapComputeS.computeIfAbsent("test", key -> new ArrayList<>());
		List<String> resCD = mapComputeS.getOrDefault("test", new ArrayList<>());
		resCS.add("piyo");
		resCD.add("piyo");

		List<String> specialTestResult1 = mapComputeS.get("test");
		List<String> specialTestResult2 = mapDefaultS.get("test");

		System.out.println("ComputeIfAbsent added -> " + specialTestResult1);
		System.out.println("GetOrDefault    added -> " + specialTestResult2);
	}
}