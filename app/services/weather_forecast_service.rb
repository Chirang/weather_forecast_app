class WeatherForecastService
  def self.retrieve_weather(zip_code, address)
    cached_forecast_data = $redis.get("weather-#{zip_code}")

    if cached_forecast_data.nil?
      forecast_data = geoservice_data(address)

      if forecast_data[:error].present?
        { source: 'error', error: forecast_data[:error] }
      else
        $redis.set("weather-#{zip_code}", forecast_data.to_json)
        $redis.expire("weather-#{zip_code}", 30.minutes.to_i)
        { source: "api", weather: forecast_data }
      end
    else
      { source: "cache", weather: JSON.parse(cached_forecast_data) }
    end
  ensure
    $redis.quit if $redis.present?
  end

  private

  def self.geoservice_data(address)
    coordinates = GeocodeService.geocode_address(address)

    if coordinates[:error].present? || coordinates.nil?
      { error: coordinates[:error] }
    else
      latitude = coordinates[:latitude]
      longitude = coordinates[:longitude]
      WeatherService.fetch_weather_data(latitude, longitude)
    end
  end
end
