ENV['RACK_ENV'] = 'test'

require_relative '../app'
require 'rspec'
require 'rack/test'
require 'warden/test/helpers'
require 'warden/test/warden_helpers'
require 'timecop'

RSpec.configure do |config|
  config.include(Warden::Test::Helpers)

  config.after(:each) do
    Warden.test_reset!
  end
end
