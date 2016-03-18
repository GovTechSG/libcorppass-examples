require 'sinatra'
require 'corp_pass'

# Replace stub with an actual CorpPass provider for production
# The actual provider loaded is defined in config.yml.
# require 'corp_pass/providers/actual'
require_relative 'providers/stub'

# CorpPass::Logger takes in a logger (eg. Rails)
# Notification levels are defined in `lib/events.rb`
# Subscription is done using ActiveSupport notifications
# CorpPass::Logger.new(::Logger.new(STDOUT)).subscribe_all

CorpPass.load_yaml!(File.join(File.dirname(__FILE__), 'config.yml'), 'MY_ENV')
CorpPass.setup!

use Warden::Manager do |manager|
  CorpPass.setup_warden_manager!(manager)
end

##
# This is the failure app called by Warden as defined in config.yml.
class ExampleFailureApp
  def call(_e)
    [403, { 'Content-Type' => 'text/plain' }, ['Bad End']]
  end
end

enable :sessions

get '/' do
  'Hello, world!'
end

get '/auth_required' do
  if env['warden'].authenticated? CorpPass::WARDEN_SCOPE
    'Authenticated'
  else
    error 403
  end
end

get '/logout' do
  env['warden'].logout
end
