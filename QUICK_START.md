# Quick Start - Local MongoDB Setup

## The Issue
Homebrew installation is having issues. Here are alternative ways to get MongoDB running locally:

## Option 1: Direct Download (Recommended for Local Setup)

1. **Download MongoDB Community Edition:**
   - Visit: https://www.mongodb.com/try/download/community
   - Select:
     - Version: 7.0 (more stable) or 8.0
     - Platform: macOS
     - Package: TGZ

2. **Extract and Setup:**
   ```bash
   cd ~
   tar -xzf mongodb-macos-*.tgz
   mv mongodb-macos-* mongodb
   export PATH=$PATH:~/mongodb/bin
   ```

3. **Create Data Directory:**
   ```bash
   mkdir -p ~/mongodb-data
   ```

4. **Start MongoDB:**
   ```bash
   ~/mongodb/bin/mongod --dbpath ~/mongodb-data
   ```

5. **Keep MongoDB Running:**
   - Open a new terminal window/tab
   - Keep the MongoDB process running
   - In another terminal, run your app: `ruby app.rb`

## Option 2: Fix Homebrew and Retry

If you want to fix Homebrew first:

```bash
# Update Homebrew
brew update

# Clean up
brew cleanup

# Try installing again
brew tap mongodb/brew
brew install mongodb-community@7.0
brew services start mongodb-community
```

## Option 3: MongoDB Atlas (Cloud - No Installation Needed)

This is the easiest option - no local installation required:

1. Sign up at https://www.mongodb.com/cloud/atlas/register
2. Create a free cluster
3. Get your connection string
4. Set environment variable:
   ```bash
   export MONGODB_URI="your-connection-string-here"
   ```
5. Restart your app

See `MONGODB_SETUP.md` for detailed Atlas instructions.

## Test Your Setup

Once MongoDB is running (any method), test it:

```bash
# Test the API
curl http://localhost:4567/api/restaurants

# Should return: [] (empty array if no data, or connection error if MongoDB isn't running)
```

## Current Status

- ✅ App is running at http://localhost:4567
- ✅ Code is ready for MongoDB connection
- ⏳ Waiting for MongoDB to be installed/started

