class WeatherController < BaseController

  def forecast
    address = params[:address]
    zip_code = extract_zip_code(address)
    if zip_code.present?
      weather_data = retrieve_cached_weather(zip_code, address)

      if weather_data[:source] == "error"
        render json: { error: weather_data[:error] }, status: :unprocessable_entity
      else
        render json: { source: weather_data[:source], weather: weather_data[:weather] }, status: :ok
      end
    else
      render json: { error: "Invalid address format #{address}. Please provide a valid address with ZIP code(only india and US)" }, status: :unprocessable_entity
    end
  end

  private

  def extract_zip_code(address)
    india_zip_code_regex = /\b\d{6}\b/
    us_zip_code_regex = /\b\d{5}(?:-\d{4})?\b/

    zip_code = address.match(india_zip_code_regex) || address.match(us_zip_code_regex)
    zip_code[0] if zip_code.present?
  end

  def retrieve_cached_weather(zip_code, address)
    cached_forecast_data = redis.get("weather-#{zip_code}")
  
    if cached_forecast_data.nil?
      forecast_data = geoservice_data(address)

      if forecast_data[:error].present?
        { source: 'error', error: forecast_data[:error]  }
      else
        redis.set("weather-#{zip_code}", forecast_data.to_json)
        redis.expire("weather-#{zip_code}", 30.minutes.to_i)
        { source: "api", weather: forecast_data }
      end
    else
      { source: "cache", weather: JSON.parse(cached_forecast_data) }
    end
  ensure
    redis.quit if redis.present?
  end

  def geoservice_data(address)
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
