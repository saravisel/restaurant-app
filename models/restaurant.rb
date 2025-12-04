require_relative '../config/database'

class Restaurant
  attr_accessor :id, :name, :cuisine, :location, :rating, :price_range, :description, :created_at, :updated_at

  def initialize(attributes = {})
    @id = attributes[:_id] || attributes[:id]
    @name = attributes[:name]
    @cuisine = attributes[:cuisine]
    @location = attributes[:location] || {}
    @rating = attributes[:rating] || 0
    @price_range = attributes[:price_range]
    @description = attributes[:description]
    @created_at = attributes[:created_at] || Time.now
    @updated_at = attributes[:updated_at] || Time.now
  end

  def self.collection
    Database::Connection.client[:restaurants]
  end

  def self.all
    collection.find.map { |doc| new(doc) }
  end

  def self.find(id)
    begin
      object_id = id.is_a?(BSON::ObjectId) ? id : BSON::ObjectId.from_string(id.to_s)
      doc = collection.find(_id: object_id).first
      doc ? new(doc) : nil
    rescue BSON::ObjectId::Invalid
      nil
    end
  end

  def self.find_by_name(name)
    collection.find(name: /#{name}/i).map { |doc| new(doc) }
  end

  def self.find_by_cuisine(cuisine)
    collection.find(cuisine: /#{cuisine}/i).map { |doc| new(doc) }
  end

  def save
    @updated_at = Time.now
    if @id
      self.class.collection.update_one(
        { _id: @id },
        { '$set' => to_hash }
      )
    else
      @created_at = Time.now
      result = self.class.collection.insert_one(to_hash)
      @id = result.inserted_id
    end
    self
  end

  def destroy
    return false unless @id
    self.class.collection.delete_one(_id: @id)
    true
  end

  def to_hash
    {
      name: @name,
      cuisine: @cuisine,
      location: @location,
      rating: @rating,
      price_range: @price_range,
      description: @description,
      created_at: @created_at,
      updated_at: @updated_at
    }
  end

  def to_json(*args)
    {
      id: @id.to_s,
      name: @name,
      cuisine: @cuisine,
      location: @location,
      rating: @rating,
      price_range: @price_range,
      description: @description,
      created_at: @created_at,
      updated_at: @updated_at
    }.to_json(*args)
  end
end

