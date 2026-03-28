# MongoDB Setup Guide

## Option 1: MongoDB Atlas (Cloud - Recommended)

MongoDB Atlas is a free cloud database service. Follow these steps:

1. **Sign up for MongoDB Atlas** (free tier available):
   - Go to https://www.mongodb.com/cloud/atlas/register
   - Create a free account

2. **Create a Cluster**:
   - Choose the free M0 tier
   - Select a cloud provider and region
   - Wait for cluster creation (2-3 minutes)

3. **Create Database User**:
   - Go to "Database Access" in the left menu
   - Click "Add New Database User"
   - Choose "Password" authentication
   - Create username and password (save these!)
   - Set user privileges to "Atlas admin" or "Read and write to any database"
   - Click "Add User"

4. **Whitelist Your IP Address**:
   - Go to "Network Access" in the left menu
   - Click "Add IP Address"
   - Click "Allow Access from Anywhere" (for development) or add your specific IP
   - Click "Confirm"

5. **Get Connection String**:
   - Go to "Database" in the left menu
   - Click "Connect" on your cluster
   - Choose "Connect your application"
   - Copy the connection string (looks like: `mongodb+srv://username:password@cluster.mongodb.net/`)
   - Replace `<password>` with your actual password
   - Add database name at the end: `mongodb+srv://username:password@cluster.mongodb.net/restaurant_app`

6. **Set Environment Variable**:
   ```bash
   export MONGODB_URI="mongodb+srv://username:password@cluster.mongodb.net/restaurant_app"
   ```

7. **Run the app**:
   ```bash
   ruby app.rb
   ```

## Option 2: Local MongoDB Installation

If you prefer to run MongoDB locally:

1. **Install MongoDB**:
   ```bash
   brew tap mongodb/brew
   brew install mongodb-community
   ```

2. **Start MongoDB**:
   ```bash
   brew services start mongodb-community
   ```
   
   Or manually:
   ```bash
   mongod --config /opt/homebrew/etc/mongod.conf
   ```

3. **Run the app** (uses default local connection):
   ```bash
   ruby app.rb
   ```

## Testing the Connection

Once MongoDB is set up, test the connection:

```bash
# Health check
curl http://localhost:4567/

# Get all restaurants (should return empty array initially)
curl http://localhost:4567/api/restaurants

# Create a test restaurant
curl -X POST http://localhost:4567/api/restaurants \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Restaurant",
    "cuisine": "Italian",
    "location": {"address": "123 Main St", "city": "New York"},
    "rating": 4.5,
    "price_range": "$$",
    "description": "A test restaurant"
  }'
```


