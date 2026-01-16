require 'rack/test'
require 'rspec'
require 'json'

ENV['RACK_ENV'] = 'test'

require_relative '../app'

module RSpecMixin
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.before(:each) do
    # Clean test data before each test
    RESTAURANTS_COLLECTION.delete_many
  end
end
