require File.dirname(__FILE__) + '/spec_helper.rb'

describe Rdb4o::Database do
  
  it "should require dbfile" do
    lambda {
      Rdb4o::Database.setup
    }.should raise_error(ArgumentError)
  end
  
  it "should create database" do
    Rdb4o::Database.setup(:dbfile => "test.db4o")
  end
  
  it "should setup server"
  
  it "#[] should return database connection" do
    Rdb4o::Database[:default].should be_a_kind_of(Java::ComDb4oInternal::IoAdaptedObjectContainer)
  end
  
end
