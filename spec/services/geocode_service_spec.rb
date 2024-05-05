require 'rails_helper'
require_relative '../../app/services/geocode_service'

RSpec.describe GeocodeService do
  describe '.geocode_address' do
    let(:valid_address) { '1600 Amphitheatre Parkway, Mountain View, CA' }

    context 'when geocoding succeeds' do
      it 'returns latitude and longitude' do
        allow(URI).to receive(:open).and_return(
          double(read: '{"features":[{"geometry":{"coordinates":[-122.0842499,37.4219999]}}]}')
        )

        result = GeocodeService.geocode_address(valid_address)
        expect(result).to eq({ latitude: 37.4219999, longitude: -122.0842499 })
      end
    end

    context 'when location not found' do
      it 'returns an error message' do
        allow(URI).to receive(:open).and_return(
          double(read: '{"features":[]}')
        )

        result = GeocodeService.geocode_address(valid_address)
        expect(result).to eq({ error: 'Our service does not support this location' })
      end
    end

    context 'when JSON parsing error occurs' do
      it 'returns a parsing error message' do
        allow(URI).to receive(:open).and_return(
          double(read: 'Invalid JSON')
        )

        result = GeocodeService.geocode_address(valid_address)
        expect(result).to eq({ error: 'Failed to parse JSON response from the geocoding service.' })
      end
    end

    context 'when API request times out' do
      it 'returns a timeout error message' do
        allow(URI).to receive(:open).and_raise(Timeout::Error)

        result = GeocodeService.geocode_address(valid_address)
        expect(result).to eq({ error: 'The API request timed out.' })
      end
    end

    context 'when connection error occurs' do
      it 'returns a connection error message' do
        allow(URI).to receive(:open).and_raise(Errno::ECONNREFUSED)

        result = GeocodeService.geocode_address(valid_address)
        expect(result).to eq({ error: 'Failed to connect to the geocoding service.' })
      end
    end

    context 'when unexpected error occurs' do
      it 'returns a generic error message' do
        allow(URI).to receive(:open).and_raise(StandardError.new('Unexpected Error'))

        result = GeocodeService.geocode_address(valid_address)
        expect(result).to eq({ error: 'Unexpected Error' })
      end
    end
  end
end
