require 'sinatra/base'
require_relative 'monkeypatches'
require_relative 'user'

class ReaderFix < Sinatra::Base
  get '/:username/:token/share' do
    user   = User.by_username(params[:username])
    user ||= User.create(params.hash_from(:username, :token))

    raise "HACKER" unless user.validate_token(params[:token])

    user.share!(params.hash_from(:url, :title, :source, :shorturl))
  end

  get '/:username/rss.xml' do
    "foo"
  end
end