require 'redis'

# Specify Redis server connection details
REDIS_CONFIG = {
  host: 'localhost',
  port: 6379, # Default Redis port
  db: 0,      # Redis database number
  password: nil # Password (if Redis server requires authentication)
}

# Create a global Redis client instance
$redis = Redis.new(REDIS_CONFIG)
