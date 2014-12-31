# Chargepoint

A (very incomplete) gem to wrap the ChargePoint network JSON APIs. This is only a stub for the tiny bit I needed for a project; I'll grow it more as I have time or as you submit pull requests.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chargepoint'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chargepoint

## Usage

    #!/usr/bin/env ruby
    require 'chargepoint'
    
    # Possible, but ill-advised
    credentials = {:user_name => "me", :user_password => "seekrit"}
    
    # Better, as long as you put 'chargepoint.yml' in your .gitignore
    credentials = YAML.load_file('chargepoint.yml')
    
    ChargePoint::API.authenticate(credentials)
    json_response = ChargePoint::API.get_charge_spots(latitude, longitude, search_radius)

## Contributing

1. Fork it ( https://github.com/purp/chargepoint/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
