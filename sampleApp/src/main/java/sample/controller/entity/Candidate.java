package sample.controller.entity;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * @author gebara 2017/12/03.
 */
@Getter
@AllArgsConstructor
public class Candidate {
	private long id;
	private String name;
	private boolean delete;
}
