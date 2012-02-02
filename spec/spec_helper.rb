require 'simplecov'
SimpleCov.start
require 'ohm'

RSpec.configure do |conf|
  conf.before(:each) do
    Ohm.redis.flushdb
  end
end
