# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chargepoint/version'

Gem::Specification.new do |spec|
  spec.name          = "chargepoint"
  spec.version       = ChargePoint::VERSION
  spec.authors       = ["Jim Meyer"]
  spec.email         = ["jim@geekdaily.org"]
  spec.summary       = %q{A gem to wrap the ChargePoint network JSON APIs}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "https://github.com/purp/chargepoint"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "coderay", "~> 1.1" # Adds syntax highlighting in TextMate 2
  
  spec.add_runtime_dependency "geocoder", "~> 1.2"
  spec.add_runtime_dependency "mechanize", "~> 2.7"
  spec.add_runtime_dependency "nokogiri", "~> 1.6"
end
