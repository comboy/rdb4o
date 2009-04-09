package app.models.java;
import com.rdb4o.Rdb4oModel;

public class Person extends Rdb4oModel {

  public Person () {
      // Set all stirng empty and all integers to 0
  }

	private String name;
	private int age;
          
  public void setName(String name) { this.name = name; }
  public String getName() { return this.name; }

  public void setAge(int age) { this.age = age; }
  public int getAge() { return this.age; }

}