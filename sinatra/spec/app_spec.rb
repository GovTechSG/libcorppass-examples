require_relative 'spec_helper'

describe 'Example CorpPass Sinatra app' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  ##
  # A mock User class, supplied by the application. It needs to have two methods,
  # serialize and self.deserialize.
  class MockUser
    def serialize
      'serialized username'
    end

    def self.deserialize(_request)
      'deserialized username'
    end
  end

  before(:all) do
    Timecop.freeze
    @user = MockUser.new
  end

  after(:all) do
    Timecop.return
  end

  it 'says hello' do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to eq('Hello, world!')
  end

  it 'logs in' do
    login_as(@user)
    get '/auth_required'
    expect(last_response.body).to eq('Authenticated')
  end

  it 'logs out' do
    login_as(@user)
    get '/logout'
    get '/auth_required'
    expect(last_response.status).to eq(403)
  end

  it 'shows forbidden if not logged in' do
    get '/auth_required'
    expect(last_response.status).to eq(403)
  end

  it 'timeouts a session' do
    login_as(@user)
    get '/auth_required'

    Timecop.travel 10_000_000
    login_as(@user)
    allow(CorpPass).to receive(:logout)
    expect { get '/auth_required' }.to throw_symbol(:warden, scope: CorpPass::WARDEN_SCOPE,
                                                             type: :timeout)
  end
end
