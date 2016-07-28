require 'mongo'

module MongoAdmin
  class DB
    attr_reader :config
    attr_reader :client

    def initialize(config)
      @config = Hashie::Mash.new(config)

      @databases = []
      @collections = {}

      @client = nil
      connect!

      return @client
    end

    private

    def connect!(database = 'admin')
      host = @config.mongodb.host || 'localhost'
      port = @config.mongodb.port || 27017

      conn_str = "mongodb://"
      if @config.mongodb.user
        conn_str +="#{@config.mongodb.user}:#{@config.mongodb.password}@"
      end
      conn_str =  "#{conn_str}#{host}:#{port}"
      @client = Mongo::Client.new(conn_str, database: 'admin')
      return true
    end

  end
end
