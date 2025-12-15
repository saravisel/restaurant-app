require 'sinatra'
require 'sinatra/json'
require 'json'
require_relative 'config/database'
require_relative 'controllers/restaurants_controller'

# CORS headers
before do
  content_type :json
  headers 'Access-Control-Allow-Origin' => '*',
          'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers' => 'Content-Type'
end

# Parse JSON request body
before '/api/*' do
  if request.content_type == 'application/json'
    body = request.body.read
    request.body.rewind
    params.merge!(JSON.parse(body)) if body.length > 0
  end
end

# Handle preflight requests
options '*' do
  200
end

# Health check
get '/' do
  json message: 'Restaurant API is running', version: '1.0.0'
end

# Get all restaurants
get '/api/restaurants' do
  # return all restaurant index changessss
  restaurants = RestaurantsController.index
  json restaurants
end

# Get a specific restaurant
get '/api/restaurants/:id' do
  result = JSON.parse(RestaurantsController.show(params[:id]))
  if result['error']
    status 404
  end
  json result
end

# Create a new restaurant
post '/api/restaurants' do
  result = JSON.parse(RestaurantsController.create(params))
  if result['error']
    status 400
  else
    status 201
  end
  json result
end

# Update a restaurant
put '/api/restaurants/:id' do
  result = JSON.parse(RestaurantsController.update(params[:id], params))
  if result['error']
    status 404
  end
  json result
end

# Delete a restaurant
delete '/api/restaurants/:id' do
  result = JSON.parse(RestaurantsController.destroy(params[:id]))
  if result['error']
    status 404
  end
  json result
end

# Search restaurants
get '/api/restaurants/search/:query' do
  results = JSON.parse(RestaurantsController.search(params[:query]))
  json results
end

# Paginated restaurants
get '/api/restaurants/page/:page' do
  page = params[:page].to_i
  per_page = (params[:per_page] || 10).to_i
  result = JSON.parse(RestaurantsController.paginate(page, per_page))
  json result
end

# Sort restaurants by fields name sort field name present
get '/api/restaurants/sort/:field' do
  field = params[:field]
  order = params[:order] || 'asc'
  result = JSON.parse(RestaurantsController.sort(field, order))
  json result
end

# Error handling
error do
  status 500
  json error: 'Internal server error', message: env['sinatra.error'].message
end

not_found do
  status 404
  json error: 'Not found'
end

