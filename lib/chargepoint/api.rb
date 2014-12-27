require 'mechanize'

class ChargePoint
  class API
    @@authenticated = nil
    @@agent = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
    
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
  end
end
