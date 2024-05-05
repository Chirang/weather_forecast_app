require 'open-uri'
require 'json'

class GeocodeService
  MAPBOX_API_TIMEOUT = 2 # Timeout in seconds

  def self.geocode_address(address)
    mapbox_access_token = ENV['MAPBOX_ACCESS_TOKEN']
    url = "https://api.mapbox.com/geocoding/v5/mapbox.places/#{URI.encode_www_form_component(address)}.json?access_token=#{mapbox_access_token}"

    begin
      response = URI.open(url, open_timeout: MAPBOX_API_TIMEOUT).read
      json_response = JSON.parse(response)

      if json_response['features'].present? && json_response['features'].first['geometry'].present?
        geometry = json_response['features'].first['geometry']
        { latitude: geometry['coordinates'][1], longitude: geometry['coordinates'][0] }
      else
        { error: 'Our service does not support this location' }
      end
    rescue Timeout::Error
      { error: 'The API request timed out.' }
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, SocketError => e
      { error: 'Failed to connect to the geocoding service.' }
    rescue JSON::ParserError => e
      { error: 'Failed to parse JSON response from the geocoding service.' }
    rescue StandardError => e
      Rails.logger.error("Error geocoding address: #{e.message}")
      { error: "#{e.message}" }
    end
  end
end
