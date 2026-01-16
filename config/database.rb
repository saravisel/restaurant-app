require 'mongo'
require 'logger'

Mongo::Logger.logger.level = ::Logger::FATAL

db_name =
  if ENV['RACK_ENV'] == 'test'
    'restaurant_app_test'
  else
    'restaurant_app'
  end

DB_CLIENT = Mongo::Client.new(
  ['127.0.0.1:27017'],
  database: db_name
)

RESTAURANTS_COLLECTION = DB_CLIENT[:restaurants]