require 'rack/test'

require 'readerfix'

describe ReaderFix do
  include Rack::Test::Methods

  def app
    ReaderFix
  end

  it "should respond to google reader endpoint" do
    get '/share?source=mysource&title=mytitle&url=myurl&short-url=myshort-url'
    last_response.should be_ok
    fail "Write more tests"
  end
end