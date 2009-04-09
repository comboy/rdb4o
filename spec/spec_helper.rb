begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

require 'rdb4o'

def d(*attrs)
  attrs.each {|a| puts a.inspect }
end

Spec::Runner.configure do |config|  
  config.before(:all) do
    $CLASSPATH << File.dirname(__FILE__)
    Dir.glob("#{File.dirname(__FILE__)}/app/models/java/*.java").each do |class_file|
      if File.exists? "#{class_file.split('.')[0]}.class"
        class_name = class_file.split('/')[-1].split('.')[0]
        # FIXME: EVAL = EVIL !!!
        # should be some const_get
        model_class = eval("Java::app::models::java::#{class_name}")
        Object.const_set(class_name, model_class)
        Rdb4o.set_model(model_class)
      end
    end
  end
  
  config.after(:all) do
    Rdb4o::Database.close
    Dir["*.db4o"].each {|path| File.delete(path) }
  end
end

