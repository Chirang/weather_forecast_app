class BaseController < ApplicationController

  def redis
   Redis.new(url: ENV['REDIS_URL'])
  end
end
