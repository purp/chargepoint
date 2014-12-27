require 'mechanize'
require 'uri'
require 'geocoder'

class ChargePoint
  class API
    @@authenticated = nil
    @@agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }

    # TODO: automatically wrap these methods with authentication guard condition
    AUTHENTICATED_METHODS = [:get_charge_spots]

    def self.agent
      @@agent
    end

    def self.authenticated?
      !!@@authenticated
    end

    # TODO: automatically auth when needed and credentials available
    # TODO: add method to see if authentication is still valid
    def self.authenticate(params)
      response = JSON[agent.post('https://na.chargepoint.com/users/validate', params).content]

      @@authenticated = response['auth']
    end

    def self.get_charge_spots(latitude, longitude, search_radius=0.25, options={})
      raise 'method requires authentication' unless authenticated?

      params = params_with_filters(options)
      params.merge!(search_box_for(latitude, longitude, search_radius))

      uri = dashboard_uri_for_method
      uri.query = URI.encode_www_form(params)

      JSON[agent.get(uri.to_s).content]
    end

    private
    def self.dashboard_uri_for_method
      endpoint = caller(1)[0].scan(/\`([^']*)\'$/).flatten.first.gsub(/_([a-z])/) { $1.upcase }
      URI.join('https://na.chargepoint.com/dashboard/', endpoint)
    end

    def self.search_box_for(latitude, longitude, search_radius)
      search_box = {}

      search_box[:lat], search_box[:lng] = latitude, longitude
      search_box[:sw_lat], search_box[:sw_lng], search_box[:ne_lat], search_box[:ne_lng] = Geocoder::Calculations.bounding_box([latitude, longitude], search_radius)

      search_box
    end

    def self.params_with_filters(options)
      default_filters = {
        :estimationfee => false,
        :available => true,
        :inuse => true,
        :unknown => true,
        :cp => true,
        :other => true,
        :l3 => true,
        :l2 => true,
        :l1 => false,
        :estimate => false,
        :fee => true,
        :free => true,
        :reservable => false,
        :shared => true,
        :chademo => true,
        :saecombo => true,
        :tesla => true,
      }
      default_options = {
        :sort_by => 'distance',
        :driver_connected_station_only => false,
        :community_enabled_only => false
      }

      filters = default_filters.merge(options.delete(:filters) || {})

      params = default_options.merge(options)
      params.merge!(Hash[filters.map {|k,v| [('f_%s' % k.to_s).to_sym, v]}])

      params[:_] = Time.now.to_i

      params
    end
  end
end
