require 'bson'

class RestaurantsController
  class << self

    def index
      restaurants = RESTAURANTS_COLLECTION.find(deleted: { '$ne' => true }).to_a
      restaurants.map { |r| serialize(r) }
    end

    def show(id)
      restaurant = find_by_id(id)
      return { error: 'Restaurant not found' } unless restaurant

      serialize(restaurant)
    end

    def create(params)
      doc = {
        name: params['name'],
        city: params['city'],
        cuisine: params['cuisine'],
        rating: params['rating'].to_f,
        latitude: params['latitude']&.to_f,
        longitude: params['longitude']&.to_f,
        deleted: false,
        created_at: Time.now
      }

      result = RESTAURANTS_COLLECTION.insert_one(doc)
      serialize(doc.merge(_id: result.inserted_id))
    end

    def update(id, params)
      restaurant = find_by_id(id)
      return { error: 'Restaurant not found' } unless restaurant

      update_fields = params.slice('name', 'city', 'cuisine', 'rating')
      update_fields.delete_if { |_k, v| v.nil? }

      RESTAURANTS_COLLECTION.update_one(
        { _id: restaurant[:_id] },
        { '$set' => update_fields }
      )

      show(id)
    end

    def destroy(id)
      restaurant = find_by_id(id)
      return { error: 'Restaurant not found' } unless restaurant

      RESTAURANTS_COLLECTION.delete_one(_id: restaurant[:_id])
      { message: 'Restaurant deleted permanently' }
    end

    def soft_delete(id)
      restaurant = find_by_id(id)
      return { error: 'Restaurant not found' } unless restaurant

      RESTAURANTS_COLLECTION.update_one(
        { _id: restaurant[:_id] },
        { '$set' => { deleted: true } }
      )

      { message: 'Restaurant disabled successfully' }
    end

    def search(query)
      results = RESTAURANTS_COLLECTION.find(
        name: /#{query}/i,
        deleted: { '$ne' => true }
      ).to_a

      results.map { |r| serialize(r) }
    end

    def paginate(page, per_page)
      skip = (page - 1) * per_page

      data = RESTAURANTS_COLLECTION
               .find(deleted: { '$ne' => true })
               .skip(skip)
               .limit(per_page)
               .to_a

      {
        page: page,
        per_page: per_page,
        data: data.map { |r| serialize(r) }
      }
    end

    def sort(field, order)
      direction = order == 'desc' ? -1 : 1

      data = RESTAURANTS_COLLECTION
               .find(deleted: { '$ne' => true })
               .sort(field => direction)
               .to_a

      data.map { |r| serialize(r) }
    end

    def filter(filters)
      query = filters.reject { |_k, v| v.nil? || v.empty? }
      query[:deleted] = { '$ne' => true }

      data = RESTAURANTS_COLLECTION.find(query).to_a
      data.map { |r| serialize(r) }
    end

    def bulk_create(list)
      docs = list.map do |r|
        r.merge(
          deleted: false,
          created_at: Time.now
        )
      end

      RESTAURANTS_COLLECTION.insert_many(docs)
      { message: 'Restaurants created successfully', count: docs.size }
    end

    def top_rated(limit)
      data = RESTAURANTS_COLLECTION
               .find(deleted: { '$ne' => true })
               .sort(rating: -1)
               .limit(limit)
               .to_a

      data.map { |r| serialize(r) }
    end

    def random
      doc = RESTAURANTS_COLLECTION
              .aggregate([{ '$sample' => { size: 1 } }])
              .first

      doc ? serialize(doc) : {}
    end

    def disabled
      data = RESTAURANTS_COLLECTION
               .find(deleted: true)
               .to_a

      data.map { |r| serialize(r) }
    end

    def nearby(lat, lng, radius)
      lat = lat.to_f
      lng = lng.to_f
      radius = radius.to_f

      results = RESTAURANTS_COLLECTION
                  .find(deleted: { '$ne' => true })
                  .to_a
                  .select do |r|
                    next false unless r[:latitude] && r[:longitude]

                    distance_km(
                      lat,
                      lng,
                      r[:latitude],
                      r[:longitude]
                    ) <= radius
                  end

      results.map { |r| serialize(r) }
    end

    def recent(days)
      threshold = Time.now - (days * 24 * 60 * 60)

      data = RESTAURANTS_COLLECTION
                .find({
                  created_at: { '$gte' => threshold },
                  deleted: { '$ne' => true }
                })
                .to_a

      data.map { |r| serialize(r) }
    end



    private

    def find_by_id(id)
      RESTAURANTS_COLLECTION.find(_id: BSON::ObjectId(id)).first
    rescue BSON::Error::InvalidObjectId
      nil
    end

    def serialize(doc)
      doc.merge(id: doc[:_id].to_s).tap { |d| d.delete(:_id) }
    end

    def distance_km(lat1, lon1, lat2, lon2)
      rad = Math::PI / 180
      r = 6371 # Earth radius in km

      dlat = (lat2 - lat1) * rad
      dlon = (lon2 - lon1) * rad

      a =
        Math.sin(dlat / 2)**2 +
        Math.cos(lat1 * rad) *
        Math.cos(lat2 * rad) *
        Math.sin(dlon / 2)**2

      c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
      r * c
    end


  end
end
