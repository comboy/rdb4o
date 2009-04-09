module Rdb4o
  
  module Model
    # To let others know where to find Rdb4oBase.class
    def self.base_classpath
      "#{File.dirname(File.expand_path(__FILE__))}/java"
    end
    
    def self.included(base) #:nodoc:
       base.extend(ClassMethods)
       base.send(:include, InstanceMethods)
    end
    
    class Finder < Java::com::rdb4o::RubyPredicate
      attr_accessor :proc     
      def rubyMatch(obj)
        @proc.call obj
      end
    end
    
    module ClassMethods
      
      def new(attrs = {})
        instance = super()
        instance.update(attrs)
        instance
      end
      
      def create(attrs = {})
        instance = self.new(attrs)
        instance.save
        instance
      end
      
      # Returns all models matching conditions hash *OR* proc
      def all(conditions = {}, &proc)
        if proc
          finder = Finder.new
          finder.proc = proc
          result = self.database.query(finder)
        elsif !conditions.empty?
          object = self.new
          object.update(conditions)
          result = self.database.get(object)
        else
          result = self.database.get(self.java_class)
        end
        
        result.to_a
      end
      
      def get_by_db4o_id(id)
        obj = database.ext.getByID(id.to_i)
        # Activate depth should be configurable
        database.activate(obj, 5)
        obj
      end
      
      # Returns database connection
      def database(name = :default)
        Rdb4o::Database[name]
      end
    end
    
    module InstanceMethods
      
      # Update object attributes
      def update(attrs = {})
        attrs.each do |key, value|
          self.send("#{key}=", value)
        end
      end
      
      # Returns false if object is stored in database, otherwize true
      def new?
        # not sure..
        self.db4o_id == 0
      end
      
      # Saves object to database
      def save
        self.class.database.set(self)
      end
      
      # Deletes object form database
      def destroy
        self.class.database.delete(self)
      end
      
      def db4o_id
        self.class.database.ext.getID(self)
      end
      
    end
  end
  
end