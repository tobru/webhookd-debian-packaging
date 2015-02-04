require_relative 'helper'

describe 'GET /' do
  user = "deployer"
  pass = "Deploy1T"
  it 'should request authentication' do
    get '/'
    last_response.status.must_equal 401
  end
  it 'should respond with authentication' do
    authorize user, pass
    get '/'
    assert last_response.ok?
    assert last_response.body.must_match "I'm running. Nice, isn't it?"
  end
  # payload has a known repository and branch name (aka configured)
  it 'should respond with 500 - webhook payload of type unknowntype not configured' do
    authorize user, pass
    post '/payload/unknowntype', 'payload' => 'empty'
    assert_equal 400, last_response.status
    assert last_response.body.must_match "Payload type unknown"
  end
end

