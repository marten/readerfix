require 'sinatra/base'

class ReaderFix < Sinatra::Base
  get '/' do
    "Hello, world"
  end
end