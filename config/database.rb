require 'mongo'

module Database
  class Connection
    @@client = nil

    def self.client
      return @@client if @@client

      # Support both local MongoDB and MongoDB Atlas
      # For MongoDB Atlas, use: mongodb+srv://username:password@cluster.mongodb.net/database_name
      # For local MongoDB, use: mongodb://localhost:27017
      database_url = ENV['MONGODB_URI'] || 'mongodb://localhost:27017'
      database_name = ENV['MONGODB_DATABASE'] || 'restaurant_app'

      # If using MongoDB Atlas connection string, extract database name from URI
      if database_url.include?('mongodb+srv://') || database_url.include?('@')
        # Extract database name from connection string if present
        if database_url.match(%r{/([^/?]+)(\?|$)})
          database_name = $1
        end
        @@client = Mongo::Client.new(database_url)
      else
        # Local MongoDB connection
        @@client = Mongo::Client.new(
          database_url,
          database: database_name
        )
      end

      puts "Connected to MongoDB: #{database_name}"
      @@client
    end

    def self.disconnect
      @@client&.close
      @@client = nil
    end
  end
end


