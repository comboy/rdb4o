module Rdb4o
  class Database
    @databases = {}
    Default_config = {:type => 'local', :port => 0, :login => '', :password => ''}

    def self.[](name)
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
       config = Default_config.merge(config)
       if config[:type].to_s == 'remote'
         puts "setting up server..."
         raise ArgumentError.new(":dbfile not specified") unless config[:dbfile]
         @databases[name] = Db4o.open_server(config[:dbfile], config[:port].to_i)
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
       if config[:type].to_s == 'remote'
         @databases[name] = Db4o.open_client('localhost', config[:port].to_i, config[:login], config[:password])
       else
         raise ArgumentError.new(":dbfile not specified") unless config[:dbfile]
         @databases[name] = Db4o.open_file config[:dbfile]
       end
    end
    
    # Close/disconnect database    
    def self.close(name = :default)
      @databases[name].close
    end
  end
end