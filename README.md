# Restaurant App

A Ruby 3.0.6 REST API application for managing restaurants with MongoDB database.

## Prerequisites

- Ruby 3.0.6
- MongoDB (running locally or connection string)
- Bundler gem

## Setup

1. **Install dependencies:**
   ```bash
   bundle install
   ```

2. **Start MongoDB** (if running locally):
   ```bash
   mongod
   ```
   
   The app is configured to connect to MongoDB at `mongodb://localhost:27017` with database name `restaurant_app`.
   You can modify these settings in `config/database.rb` if needed.

3. **Run the application:**
   ```bash
   ruby app.rb
   ```

   The server will start on `http://localhost:4567`

## API Endpoints

### Health Check
- `GET /` - API status

### Restaurants
- `GET /api/restaurants` - Get all restaurants
- `GET /api/restaurants/:id` - Get a specific restaurant
- `POST /api/restaurants` - Create a new restaurant
- `PUT /api/restaurants/:id` - Update a restaurant
- `DELETE /api/restaurants/:id` - Delete a restaurant
- `GET /api/restaurants/search/:query` - Search restaurants by name or cuisine

## Example Requests

### Create a Restaurant
```bash
curl -X POST http://localhost:4567/api/restaurants \
  -H "Content-Type: application/json" \
  -d '{
    "name": "The Gourmet Kitchen",
    "cuisine": "Italian",
    "location": {"address": "123 Main St", "city": "New York"},
    "rating": 4.5,
    "price_range": "$$$",
    "description": "Authentic Italian cuisine"
  }'
```

### Get All Restaurants
```bash
curl http://localhost:4567/api/restaurants
```

### Update a Restaurant
```bash
curl -X PUT http://localhost:4567/api/restaurants/{id} \
  -H "Content-Type: application/json" \
  -d '{
    "rating": 4.8
  }'
```

### Search Restaurants
```bash
curl http://localhost:4567/api/restaurants/search/Italian
```

## Project Structure

```
restaurant-app/
├── app.rb                 # Main Sinatra application
├── Gemfile                # Ruby dependencies
├── config/
│   └── database.rb        # MongoDB connection configuration
├── models/
│   └── restaurant.rb     # Restaurant model
├── controllers/
│   └── restaurants_controller.rb  # Restaurant controller
└── README.md              # This file
```

## Development

To use the interactive console with Pry:
```bash
pry -r ./app.rb
```

## License

MIT


# restaurant-app
