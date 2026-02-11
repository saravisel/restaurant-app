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
    params.merge!(JSON.parse(body)) if body && !body.empty?
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

# ------------------------
# COLLECTION ROUTES
# ------------------------

get '/api/restaurants' do
  json RestaurantsController.index
end

get '/api/restaurants/search/:query' do
  json RestaurantsController.search(params[:query])
end

get '/api/restaurants/filter' do
  filters = params.slice('cuisine', 'city', 'rating')
  json RestaurantsController.filter(filters)
end

get '/api/restaurants/page/:page' do
  page = params[:page].to_i
  per_page = (params[:per_page] || 10).to_i
  json RestaurantsController.paginate(page, per_page)
end

get '/api/restaurants/sort/:field' do
  field = params[:field]
  order = params[:order] || 'asc'
  json RestaurantsController.sort(field, order)
end

get '/api/restaurants/top/:limit' do
  limit = params[:limit].to_i
  json RestaurantsController.top_rated(limit)
end

get '/api/restaurants/random' do
  json RestaurantsController.random
end

post '/api/restaurants/bulk' do
  list = params['restaurants'] || []
  json RestaurantsController.bulk_create(list)
end

get '/api/restaurants/nearby' do
  lat = params[:lat]
  lng = params[:lng]
  radius = params[:radius] || 5

  unless lat && lng
    status 400
    return json error: 'lat and lng are required'
  end

  json RestaurantsController.nearby(lat, lng, radius)
end

get '/api/restaurants/recent/:days' do
  json RestaurantsController.recent(params[:days].to_i)
end

# ------------------------
# MEMBER ROUTES (LAST)
# ------------------------

get '/api/restaurants/disabled' do
  json RestaurantsController.disabled
end

get '/api/restaurants/:id' do
  result = RestaurantsController.show(params[:id])
  status 404 if result[:error]
  json result
end

post '/api/restaurants' do
  result = RestaurantsController.create(params)
  status(result[:error] ? 400 : 201)
  json result
end

put '/api/restaurants/:id' do
  result = RestaurantsController.update(params[:id], params)
  status 404 if result[:error]
  json result
end

patch '/api/restaurants/:id/disable' do
  result = RestaurantsController.soft_delete(params[:id])
  status 404 if result[:error]
  json result
end

delete '/api/restaurants/:id' do
  result = RestaurantsController.destroy(params[:id])
  status 404 if result[:error]
  json result
end

# Error handling
error do
  status 500
  json error: 'Internal server error',
       message: env['sinatra.error'].message
end

not_found do
  status 404
  json error: 'Not found'
end
