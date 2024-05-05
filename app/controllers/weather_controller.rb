class WeatherController < ApplicationController

  def forecast
    address = params[:address]
    zip_code = extract_zip_code(address)
    if zip_code.present?
      weather_data = WeatherForecastService.retrieve_weather(zip_code, address)

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
end
