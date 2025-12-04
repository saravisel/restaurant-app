require_relative '../models/restaurant'
require 'json'

class RestaurantsController
  def self.index
    restaurants = Restaurant.all
    restaurants.map(&:to_json)
  end

  def self.show(id)
    restaurant = Restaurant.find(id)
    return { error: 'Restaurant not found' }.to_json unless restaurant
    restaurant.to_json
  end

  def self.create(params)
    restaurant = Restaurant.new(
      name: params['name'],
      cuisine: params['cuisine'],
      location: params['location'] || {},
      rating: params['rating']&.to_f || 0,
      price_range: params['price_range'],
      description: params['description']
    )

    if restaurant.save
      { message: 'Restaurant created successfully', restaurant: JSON.parse(restaurant.to_json) }.to_json
    else
      { error: 'Failed to create restaurant' }.to_json
    end
  end

  def self.update(id, params)
    restaurant = Restaurant.find(id)
    return { error: 'Restaurant not found' }.to_json unless restaurant

    restaurant.name = params['name'] if params['name']
    restaurant.cuisine = params['cuisine'] if params['cuisine']
    restaurant.location = params['location'] if params['location']
    restaurant.rating = params['rating'].to_f if params['rating']
    restaurant.price_range = params['price_range'] if params['price_range']
    restaurant.description = params['description'] if params['description']

    if restaurant.save
      { message: 'Restaurant updated successfully', restaurant: JSON.parse(restaurant.to_json) }.to_json
    else
      { error: 'Failed to update restaurant' }.to_json
    end
  end

  def self.destroy(id)
    restaurant = Restaurant.find(id)
    return { error: 'Restaurant not found' }.to_json unless restaurant

    if restaurant.destroy
      { message: 'Restaurant deleted successfully' }.to_json
    else
      { error: 'Failed to delete restaurant' }.to_json
    end
  end

  def self.search(query)
    results = []
    results.concat(Restaurant.find_by_name(query))
    results.concat(Restaurant.find_by_cuisine(query))
    results.uniq { |r| r.id }.map(&:to_json)
  end
end



