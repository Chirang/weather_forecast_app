# Load Rails environment
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

# Load RSpec and its Rails integration
require 'rspec/rails'
require 'webmock/rspec'