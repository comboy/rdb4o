require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rdb4o::Model do
  
  before(:all) do
    Rdb4o::Database.setup(:dbfile => "model_spec.db4o")
  end
    
  describe "Class Methods" do
    # it "#[]"
    
    it "#all" do
      Person.all.should == []
      mike = Person.create(:name => 'Mike')
      Person.all.size.should == 1
      Person.all.should == [mike]
    end
    
    it "#all with conditions" do
      Person.create(:name => 'Timmy')
      Person.create(:name => 'Timmy')
      Person.create(:name => 'Bob')
      
      Person.all(:name => 'Timmy').size.should == 2
      Person.all(:name => 'Bob').size.should == 1
    end
    
    it "#all with proc" do
      Person.create(:name => 'Jimmy', :age => 35)
      Person.create(:name => 'Jimmy', :age => 40)
      Person.create(:name => 'Tom', :age => 45)
      
      Person.all {|p| p.name == 'Jimmy'}.size.should == 2
      Person.all {|p| p.name == 'Tom'}.size.should == 1
      Person.all {|p| p.age > 38}.size.should == 2
    end
    
    it "#get_by_db4o_id" do
      jimmy = Person.create(:name => 'Jimmy', :age => 35)
      Person.get_by_db4o_id(jimmy.db4o_id).should == jimmy
    end
    
    # it "#first"
    
    it "#new should create new object and allow to set attributes" do
      john = Person.new
      john.name = "John"
      john.name.should == "John"
      john.age = 35
      john.age.should == 35
    end
    
    it "#new should allow to pass attributes hash as param" do
      john = Person.new(:name => 'John', :age => 35)
      john.name.should == 'John'
      john.age.should == 35
    end
    
    it "#new should raise error when trying to set undefined attribute" do
      lambda {
        john = Person.new(:non_existion => "Whoo")
      }.should raise_error(NoMethodError)
    end
    
    it "#create should create new object and save it" do
      mike = Person.create(:name => 'Mike')
      mike.name.should == 'Mike'
      mike.new?.should == false
    end

  end
  
  describe "Instance Mathods" do
    it "#save should save record" do
      Person.all.should == []
      
      john = Person.new(:name => 'John')
      john.new?.should == true
      john.save
      john.new?.should == false
      
      Person.all.size.should == 1
      Person.all.should == [john]
    end
    
    it "#destroy should delete object form database" do
      john = Person.create(:name => 'John')
      Person.all.size.should == 2
      john.destroy
      Person.all.size.should == 1
    end
  
  
    it "should raise error when trying to set undefined attribute" do
      mike = Person.new
      lambda { 
        mike.non_existing = "Whooo"
      }.should raise_error(NoMethodError)
    end
    
    it "#db4o_id" do
      john = Person.new
      john.db4o_id.should == 0
      john.save
      john.db4o_id.should_not == 0
    end
    
  end
  
end
