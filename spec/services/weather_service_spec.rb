require 'rails_helper'
require 'webmock/rspec'

RSpec.describe WeatherService do
  describe '.fetch_weather_data' do
    let(:latitude) { 40.7128 }
    let(:longitude) { -74.0060 }
    let(:openweathermap_api_key) { ENV['OPENWEATHERMAP_API_KEY'] }

    it 'returns weather data for valid latitude and longitude' do
      # Stub the API request with a mock response
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?lat=#{latitude}&lon=#{longitude}&units=metric&appid=#{openweathermap_api_key}")
        .to_return(status: 200, body: '{"coord":{"lon":-74.006,"lat":40.7128},"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01n"}],"main":{"temp":20.52,"feels_like":19.3,"humidity":58},"visibility":10000}')

      response = WeatherService.fetch_weather_data(latitude, longitude)

      expect(response).to be_a(Hash)
      expect(response).not_to have_key(:error)
      expect(response['coord']['lon']).to eq(-74.006)
      expect(response['coord']['lat']).to eq(40.7128)
      expect(response['weather'].first['main']).to eq('Clear')
      expect(response['main']['temp']).to eq(20.52)
      expect(response['main']['humidity']).to eq(58)
    end

    it 'handles API request timeout' do
      allow(URI).to receive(:open).and_raise(Timeout::Error)

      response = WeatherService.fetch_weather_data(latitude, longitude)

      expect(response).to be_a(Hash)
      expect(response).to have_key(:error)
      expect(response[:error]).to include('API request timed out')
    end

    it 'handles HTTP errors' do
      stub_request(:get, "https://api.openweathermap.org/data/2.5/weather?lat=#{latitude}&lon=#{longitude}&units=metric&appid=#{openweathermap_api_key}")
        .to_return(status: 404, body: 'Not Found')

      response = WeatherService.fetch_weather_data(latitude, longitude)

      expect(response).to be_a(Hash)
      expect(response).to have_key(:error)
      expect(response[:error]).to include('HTTP error')
    end

    it 'handles other standard errors' do
      allow(URI).to receive(:open).and_raise(StandardError.new('Network error'))

      response = WeatherService.fetch_weather_data(latitude, longitude)

      expect(response).to be_a(Hash)
      expect(response).to have_key(:error)
      expect(response[:error]).to include('Error fetching weather data')
    end
  end
end
