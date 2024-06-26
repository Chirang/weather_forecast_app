require 'open-uri'
require 'json'
require 'timeout'

class WeatherService
  OPENWEATHERMAP_API_TIMEOUT = 2

  def self.fetch_weather_data(latitude, longitude)
    
    openweathermap_api_key = ENV['OPENWEATHERMAP_API_KEY']
    url = "https://api.openweathermap.org/data/2.5/weather?lat=#{latitude}&lon=#{longitude}&units=metric&appid=#{openweathermap_api_key}"

    begin
      response = URI.open(url,open_timeout: OPENWEATHERMAP_API_TIMEOUT).read
      JSON.parse(response)
    rescue Timeout::Error
      { error: "API request timed out after #{OPENWEATHERMAP_API_TIMEOUT} seconds." }
    rescue OpenURI::HTTPError => e
      { error: "HTTP error: #{e.message}" }
    rescue JSON::ParserError => e
      { error: "JSON parsing error: #{e.message}" }
    rescue StandardError => e
      { error: "Error fetching weather data: #{e.message}" }
    end
  end
end
