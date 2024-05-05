require 'rails_helper'
require_relative '../../app/services/weather_forecast_service'

RSpec.describe WeatherForecastService do
  describe '.retrieve_weather' do
    let(:zip_code) { '12345' }
    let(:address) { '123 Main St, Anytown, USA' }

    context 'when forecast data is not cached' do
      before do
        allow(WeatherForecastService).to receive(:geoservice_data).and_return(
          { latitude: 40.7128, longitude: -74.0060 }
        )
      end

      it 'fetches weather data from API and caches it' do
        zip_code = '12345'
        address = 'New York City'
        latitude = 40.7128
        longitude = -74.006

        allow($redis).to receive(:get).with("weather-#{zip_code}").and_return(nil)
        
        forecast_data = { latitude: 40.7128, longitude: -74.006 }
        allow(WeatherForecastService).to receive(:geoservice_data).with(address).and_return(forecast_data)
        

        latitude = forecast_data[:latitude]
        longitude = forecast_data[:longitude]
        

        expected_json_data = {
          latitude: latitude,
          longitude: longitude
        }
        

        expect($redis).to receive(:set).with("weather-#{zip_code}", expected_json_data.to_json)
        expect($redis).to receive(:expire).with("weather-#{zip_code}", 30.minutes.to_i)
        

        result = WeatherForecastService.retrieve_weather(zip_code, address)
        

        expect(result[:source]).to eq('api')
        expect(result[:weather]).to eq(expected_json_data)
      end


      it 'handles error from geoservice_data' do
        allow(WeatherForecastService).to receive(:geoservice_data).and_return(
          { error: 'Geocoding service error' }
        )

        result = WeatherForecastService.retrieve_weather(zip_code, address)

        expect(result[:source]).to eq('error')
        expect(result[:error]).to eq('Geocoding service error')
      end
    end

    context 'when forecast data is cached' do
      before do
        allow($redis).to receive(:get).with("weather-#{zip_code}").and_return(
          { latitude: 40.7128, longitude: -74.0060 }.to_json
        )
      end

      it 'returns weather data from cache' do
        result = WeatherForecastService.retrieve_weather(zip_code, address)
      
        expected_weather_data = {
          latitude: 40.7128,
          longitude: -74.0060
        }

        actual_weather_data = result[:weather].transform_keys(&:to_sym)
      
        expect(result[:source]).to eq('cache')
        expect(actual_weather_data).to eq(expected_weather_data)
      end
    end
  end
end
