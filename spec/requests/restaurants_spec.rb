require 'spec_helper'
require 'json'

RSpec.describe 'Restaurants API', type: :request do

  let(:restaurant_payload) do
    {
      name: 'Test Cafe',
      city: 'Chennai',
      cuisine: 'Indian',
      rating: 4.5
    }
  end

  def create_restaurant(payload = restaurant_payload)
    post '/api/restaurants',
         payload.to_json,
         { 'CONTENT_TYPE' => 'application/json' }

    JSON.parse(last_response.body)
  end

  # ------------------------
  # CREATE
  # ------------------------
  describe 'POST /api/restaurants' do
    it 'creates a restaurant' do
      response = create_restaurant

      expect(last_response.status).to eq(201)
      expect(response['name']).to eq('Test Cafe')
      expect(response['id']).not_to be_nil
    end
  end

  # ------------------------
  # READ ALL
  # ------------------------
  describe 'GET /api/restaurants' do
    it 'returns all restaurants' do
      create_restaurant

      get '/api/restaurants'

      expect(last_response.status).to eq(200)

      body = JSON.parse(last_response.body)
      expect(body).to be_an(Array)
      expect(body.length).to eq(1)
      expect(body.first['name']).to eq('Test Cafe')
    end
  end

  # ------------------------
  # READ BY ID
  # ------------------------
  describe 'GET /api/restaurants/:id' do
    it 'returns a specific restaurant' do
      restaurant = create_restaurant

      get "/api/restaurants/#{restaurant['id']}"

      expect(last_response.status).to eq(200)

      body = JSON.parse(last_response.body)
      expect(body['name']).to eq('Test Cafe')
    end
  end

  # ------------------------
  # UPDATE
  # ------------------------
  describe 'PUT /api/restaurants/:id' do
    it 'updates a restaurant' do
      restaurant = create_restaurant

      put "/api/restaurants/#{restaurant['id']}",
          { rating: 4.9 }.to_json,
          { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)

      body = JSON.parse(last_response.body)
      expect(body['rating']).to eq(4.9)
    end
  end

  # ------------------------
  # SOFT DELETE
  # ------------------------
  describe 'PATCH /api/restaurants/:id/disable' do
    it 'soft deletes a restaurant' do
      restaurant = create_restaurant

      patch "/api/restaurants/#{restaurant['id']}/disable"

      expect(last_response.status).to eq(200)

      get '/api/restaurants'
      body = JSON.parse(last_response.body)

      expect(body).to eq([])
    end
  end

  # ------------------------
  # HARD DELETE
  # ------------------------
  describe 'DELETE /api/restaurants/:id' do
    it 'hard deletes a restaurant' do
      restaurant = create_restaurant

      delete "/api/restaurants/#{restaurant['id']}"

      expect(last_response.status).to eq(200)

      get "/api/restaurants/#{restaurant['id']}"
      expect(last_response.status).to eq(404)
    end
  end

  # ------------------------
  # SEARCH
  # ------------------------
  describe 'GET /api/restaurants/search/:query' do
    it 'searches restaurants by name' do
      create_restaurant(
        name: 'Italian Bistro',
        city: 'Rome',
        cuisine: 'Italian',
        rating: 4.2
      )

      create_restaurant(
        name: 'Indian Spice',
        city: 'Chennai',
        cuisine: 'Indian',
        rating: 4.5
      )

      get '/api/restaurants/search/Italian'

      body = JSON.parse(last_response.body)
      expect(body.length).to eq(1)
      expect(body.first['cuisine']).to eq('Italian')
    end
  end

  # ------------------------
  # PAGINATION
  # ------------------------
  describe 'GET /api/restaurants/page/:page' do
    it 'returns paginated restaurants' do
      3.times do |i|
        create_restaurant(
          name: "Cafe #{i}",
          city: 'Chennai',
          cuisine: 'Indian',
          rating: 4.0
        )
      end

      get '/api/restaurants/page/1?per_page=2'

      body = JSON.parse(last_response.body)
      expect(body['page']).to eq(1)
      expect(body['data'].length).to eq(2)
    end
  end

  # ------------------------
  # SORT
  # ------------------------
  describe 'GET /api/restaurants/sort/:field' do
    it 'sorts restaurants by rating desc' do
      create_restaurant(
        name: 'Low Rated',
        city: 'City',
        cuisine: 'Indian',
        rating: 3.0
      )

      create_restaurant(
        name: 'High Rated',
        city: 'City',
        cuisine: 'Indian',
        rating: 5.0
      )

      get '/api/restaurants/sort/rating?order=desc'

      body = JSON.parse(last_response.body)
      expect(body.first['rating']).to eq(5.0)
    end
  end

  # ------------------------
  # FILTER
  # ------------------------
  describe 'GET /api/restaurants/filter' do
    it 'filters restaurants by city and cuisine' do
      create_restaurant(
        name: 'Filter Test',
        city: 'Chennai',
        cuisine: 'Indian',
        rating: 4.0
      )

      create_restaurant(
        name: 'Other',
        city: 'Mumbai',
        cuisine: 'Chinese',
        rating: 4.0
      )

      get '/api/restaurants/filter?city=Chennai&cuisine=Indian'

      body = JSON.parse(last_response.body)
      expect(body.length).to eq(1)
      expect(body.first['city']).to eq('Chennai')
    end
  end

  # ------------------------
  # BULK CREATE
  # ------------------------
  describe 'POST /api/restaurants/bulk' do
    it 'creates multiple restaurants' do
      payload = {
        restaurants: [
          {
            name: 'Bulk One',
            city: 'City',
            cuisine: 'Indian',
            rating: 4.1
          },
          {
            name: 'Bulk Two',
            city: 'City',
            cuisine: 'Chinese',
            rating: 4.3
          }
        ]
      }

      post '/api/restaurants/bulk',
           payload.to_json,
           { 'CONTENT_TYPE' => 'application/json' }

      body = JSON.parse(last_response.body)
      expect(body['count']).to eq(2)
    end
  end

  # ------------------------
  # TOP RATED
  # ------------------------
  describe 'GET /api/restaurants/top/:limit' do
    it 'returns top rated restaurants' do
      create_restaurant(
        name: 'Top One',
        city: 'City',
        cuisine: 'Indian',
        rating: 5.0
      )

      create_restaurant(
        name: 'Lower',
        city: 'City',
        cuisine: 'Indian',
        rating: 3.0
      )

      get '/api/restaurants/top/1'

      body = JSON.parse(last_response.body)
      expect(body.length).to eq(1)
      expect(body.first['rating']).to eq(5.0)
    end
  end

  # ------------------------
  # RANDOM
  # ------------------------
  describe 'GET /api/restaurants/random' do
    it 'returns a random restaurant' do
      create_restaurant(
        name: 'Random Cafe',
        city: 'City',
        cuisine: 'Indian',
        rating: 4.0
      )

      get '/api/restaurants/random'

      body = JSON.parse(last_response.body)
      expect(body['name']).to eq('Random Cafe')
    end
  end

  # -------------------------
  # DISABLED
  # -------------------------
  describe 'GET /api/restaurants/disabled' do
    it 'returns soft deleted restaurants' do
      restaurant = create_restaurant

      patch "/api/restaurants/#{restaurant['id']}/disable"

      get '/api/restaurants/disabled'

      body = JSON.parse(last_response.body)
      expect(body.length).to eq(1)
      expect(body.first['id']).to eq(restaurant['id'])
    end
  end

  # ----------------------------------
  # nearby restaurants within radius
  # ----------------------------------

  describe 'GET /api/restaurants/nearby' do
    it 'returns nearby restaurants within radius' do
      create_restaurant(
        name: 'Nearby Cafe',
        city: 'Bangalore',
        cuisine: 'Indian',
        rating: 4.5,
        latitude: 12.9716,
        longitude: 77.5946
      )

      create_restaurant(
        name: 'Far Cafe',
        city: 'Mysore',
        cuisine: 'Indian',
        rating: 4.0,
        latitude: 12.2958,
        longitude: 76.6394
      )

      get '/api/restaurants/nearby?lat=12.9716&lng=77.5946&radius=5'

      body = JSON.parse(last_response.body)
      expect(body.length).to eq(1)
      expect(body.first['name']).to eq('Nearby Cafe')
    end
  end

  describe 'GET /api/restaurants/recent/:days' do
    it 'returns restaurants created within X days' do
      create_restaurant # created now

      get '/api/restaurants/recent/1'

      body = JSON.parse(last_response.body)
      expect(body.length).to eq(1)
    end
  end
end
