require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe 'GET #forecast' do
    let(:valid_address) { '12345, USA' }
    let(:invalid_address) { 'Invalid Address' }

    context 'with valid address containing zip code' do
      it 'returns weather data successfully' do
        allow(WeatherForecastService).to receive(:retrieve_weather).and_return(
          source: 'api',
          weather: { temperature: 25, condition: 'Sunny' }
        )

        get :forecast, params: { address: valid_address }

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({
          'source' => 'api',
          'weather' => { 'temperature' => 25, 'condition' => 'Sunny' }
        })
      end

      it 'renders error response if weather data retrieval fails' do
        allow(WeatherForecastService).to receive(:retrieve_weather).and_return(
          source: 'error',
          error: 'Weather data not available'
        )

        get :forecast, params: { address: valid_address }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({ 'error' => 'Weather data not available' })
      end
    end

    context 'with invalid address format' do
      it 'renders error response' do
        get :forecast, params: { address: invalid_address }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to eq({
          'error' => 'Invalid address format Invalid Address. Please provide a valid address with ZIP code(only india and US)'
        })
      end
    end
  end

  describe '#extract_zip_code' do
    it 'extracts ZIP code from address' do
      controller = WeatherController.new
      address = '12345, USA'
      zip_code = controller.send(:extract_zip_code, address)

      expect(zip_code).to eq('12345')
    end

    it 'returns nil for invalid address format' do
      controller = WeatherController.new
      address = 'Invalid Address'
      zip_code = controller.send(:extract_zip_code, address)

      expect(zip_code).to be_nil
    end
  end
end
