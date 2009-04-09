$: << File.dirname(__FILE__)

include Java

$CLASSPATH << "#{File.dirname(__FILE__)}/java"

begin
   require 'java/db4o.jar'
rescue LoadError
   begin 
      require ENV['DB4O_JAR'].to_s
   rescue LoadError
      raise "Rdb4o ERROR: Could not find db4objects library, put it in my lib/java dir, or try setting environment variable DB4O_JAR to db4objects jar location (You can get it at www.db4o.com)" 
   end
end

# Rdb4o

module Rdb4o
  Db4o = com.db4o.Db4o
  
  # Includes Rdb4o::Base module into given class
  def self.set_model(some_class)     
   some_class = Object.const_get(some_class) if some_class.class == 'String'
   some_class.class_eval "include Rdb4o::Model"
  end  
  
end


require 'rdb4o/database'
require 'rdb4o/model'
