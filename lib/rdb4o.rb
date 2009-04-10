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

Db4o = com.db4o.Db4o

# Rdb4o

module Rdb4o

   # Includes Rdb4o::Base module into given class

   def self.set_model(some_class)     
     some_class = Object.const_get(some_class) if some_class.class == 'String'
     some_class.class_eval "include Rdb4o::Base"
   end  
  
   # Errors class heavily is heavily based on the same one from ActiveRecord
   # (To let error_messages_for work properly)
   
   class Errors
     
     
     
    include Enumerable

    def initialize(base) # :nodoc:
      @base, @errors = base, {}
    end

    @@default_error_messages = {
      :empty => "can't be empty",
      :taken => "has already been taken",
      :invalid => "is invalid",
    }

    # Holds a hash with all the default error messages that can be replaced by your own copy or localizations.
    class << self
      attr_accessor :default_error_messages
    end


    # ADds a new error
    def add(attribute, msg = @@default_error_messages[:invalid])
      @errors[attribute.to_s] = [] if @errors[attribute.to_s].nil?
      @errors[attribute.to_s] << msg
    end

    # Returns true if the specified +attribute+ has errors associated with it.
    def invalid?(attribute)
      !@errors[attribute.to_s].nil?
    end

    # Returns error msg/msgs associated with given attribute
    def on(attribute)
      errors = @errors[attribute.to_s]
      return nil if errors.nil?
      errors.size == 1 ? errors.first : errors
    end

    alias :[] :on

    # Returns errors assigned to the base object through add_to_base according to the normal rules of on(attribute).
    def on_base
      on(:base)
    end

    # Yields each attribute and associated message per error added.
    def each
      @errors.each_key { |attr| @errors[attr].each { |msg| yield attr, msg } }
    end

    # Yields each full error message added. So Person.errors.add("first_name", "can't be empty") will be returned
    # through iteration as "First name can't be empty".
    def each_full
      full_messages.each { |msg| yield msg }
    end

    # Returns all the full error messages in an array.
    def full_messages
      full_messages = []
      @errors.each_key do |attr|
        @errors[attr].each do |msg|
          next if msg.nil?
          if attr == "base"
            full_messages << msg
          else
            full_messages << @base.class.human_attribute_name(attr) + " " + msg
          end
        end
      end
      full_messages
    end

    # Returns true if no errors have been added.
    def empty?
      @errors.empty?
    end

    # Removes all errors that have been added.
    def clear
      @errors = {}
    end

    # Returns the total number of errors added. Two errors added to the same attribute will be counted as such.
    def size
      @errors.values.inject(0) { |error_count, attribute| error_count + attribute.size }
    end

    alias_method :count, :size
    alias_method :length, :size

  end
   
   # Main module, to use it just include it in a java class that you want
   # to use with db4o
   module Base
     
     
      # To let others know where to find Rdb4oBase.class
      def self.base_classpath
        "#{File.dirname(File.expand_path(__FILE__))}/java"
      end
      
      # Validates the object
      def validate
        errors.clear
        self.class.validation_methods.each do |method|
          method.call self
        end
      end
            
      def errors
        @errors ||= Errors.new(self)
      end
      
      def valid?
        validate
        errors.empty?
      end
      
      # Saves and updates the object 
      def save         
         before_save if self.respond_to? 'before_save'
         
         if self.respond_to? 'created_at' and created_at == nil
           self.created_at = Time.now
         end
         if self.respond_to? 'updated_at' 
           self.updated_at = Time.now
         end
         if self.valid? 
           self.class.database.set self
           after_save if self.respond_to? 'before_save'
           true
         else
           false
         end
      end

      # Destroys object in database
      def delete
         self.class.database.delete self
      end
      
      # Aliast to delete
      def destroy
        delete
      end
      
      # Db4o internal object id (not UUID !)
      def db4o_id
        self.class.database.ext.getID self
      end
     
      def self.included(base_class) #:nodoc:
         #FIXME: EVAL EVIL !
         base_class.class_eval '@@validation_methods = []'
         base_class.extend(ClassMethods)
         
      end
     
      
      module ClassMethods
                                        
         # Creates a new object with given attributes and saves it to databse
         def create(attributes)
           object = self.new
           for k,v in attributes
             object.method("#{k.to_s}=").call v
           end
           object.save
           object
         end
        
         # Find all objects from database of a given class
         def find_all
            result = self.database.get self.java_class
            ret = []
            result.each { |x| ret << x }
            ret
         end
         
         # Native query find
         def find(&proc)
           finder = Finder.new
           finder.proc = proc
           database.query finder
         end
         
         # SODA find
         def find_soda(&proc)
           q = database.query
           q.constrain self.java_class
           q = proc.call(q)
           q.execute
         end
         
         # Find objects with given attributes.         
         def find_with(attributes)
           object = self.new
           for k,v in attributes
             object.send("#{k.to_s}=".to_sym, v)
           end
           self.database.get object
         end
         
         # Get object byt db4o internal id (not UUID !)
         def get_by_db4o_id(id)
           obj = database.ext.getByID(id.to_i)
           # Activate depth should be configurable
           database.activate(obj,5)
           obj
         end
         
         def database #:nodoc:#
            #TODO: many connections
            Rdb4o::Database[:default]
         end         
         
         # Method missing provides dynamic finders. 
         # For example, to find all objects with property "name" set to "blah"
         # you can just type
         # Yourclass.find_by_name "blah"               
         
         def method_missing(name, *args)
            if match = /^find_by_([_a-zA-Z]\w*)$/.match(name.to_s)
               attribute_name = match[1]
               class_proto = self.new
               class_proto.method("#{attribute_name}=").call args[0]
               result = self.database.get class_proto
               if result.empty?
                 nil
               else
                 result[0]
               end
            end
         end
         
         def human_attrbute_name(attr)
           attr.split('_').map{ |x| x.capitalize }.join(' ')
         end
         
         ## Validations
         

        def validation_methods
          @validation_methods || []
        end
         
         def validates_presence_of(*attr_names)           
           attr_names.each do |attr|
             add_validation_to_chain do |record|
               value = record.send(attr)               
               if value.nil? or (value.class==String and value.empty?)
                 record.errors.add(attr.to_s,"can't be empty")
               end                 
             end
           end
         end
         
         def validates_uniqueness_of(*attr_names)
           attr_names.each do |attr|
             add_validation_to_chain do |record|
               value = record.send(attr)               
               if self.send("find_by_#{attr.to_s}",value) 
                 record.errors.add(attr.to_s,"must be unique")
               end
             end
           end           
         end
         
         def add_validation_to_chain(&block)           
           @validation_methods = validation_methods + [block]
         end
         
      end
   end

   # Predicate class for executing native wueries
   class Finder < Java::com::rdb4o::RubyPredicate
     attr_accessor :proc     
     def rubyMatch(obj)
       @proc.call obj
     end
   end

   
   class Database
      @databases = {}
      Default_config = {:type => 'local', :port => 0, :login => '', :password => ''}

      def self.[] name
         @databases[name]
      end

      # Preparing Object Container for a given databse      
      # 
      # Config is a hash with a following possible keys:
      # :type - type of the databse can be remote or local
      # options specific for remote type:
      #   :host - if empty, use localhost
      #   :port - can be 0 only for localhost
      #   :username - if omitted, no autentication is used
      #   :password      
      
      def self.setup_server(config, name = :default)
         config = Default_config.merge config
         if config[:type] == 'remote'
           puts "setting up server..."
           @databases[name] = Db4o.open_server(config[:dbfile],config[:port].to_i)
           @databases[name].grant_access(config[:login], config[:password])
           puts "done"
         else
           puts ":type must be set to remote in database.yml in odrder to start a server" 
         end
      end
      
      # Sets up the database. Depending on the config it opens a dbfile or connects
      # to remote database server
      def self.setup(config, name = :default)
         #TODO: error handling
         config = Default_config.merge config
         if config[:type] == 'remote'
           @databases[name] = Db4o.open_client('localhost',config[:port].to_i,config[:login],config[:password])
         else
           @databases[name] = Db4o.open_file config[:dbfile]
         end
      end

   end

end
