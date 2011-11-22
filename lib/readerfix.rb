$:.unshift(File.expand_path(File.dirname(__FILE__)))
require 'sinatra/base'
require 'atom'
require 'ohm'

require 'monkeypatches'
require 'user'

if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  Ohm.redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end

class ReaderFix < Sinatra::Base
  get '/' do
    erb :index
    <<-END
    END
  end

  get '/:username/:token/share' do
    user   = User.by_username(params[:username])
    user ||= User.create(params.hash_from(:username, :token))

    raise "HACKER" unless user.validate_token(params[:token])

    user.share!(params.hash_from(:url, :title, :source, :shorturl, :note))

    erb :share
  end

  get '/:username/:token/note' do
    erb :note
  end

  get '/:username.xml' do
    user = User.by_username(params[:username]) or raise "Unknown user"
    feed = Atom::Feed.new do |f|
      f.title = "Feed of #{user.username}"
      #f.links << Atom::Link.new(:href => "")
      f.updated = Time.parse(user.last_update)
      #f.authors << Atom::Person.new(:name => 'John Doe')
      f.id = "readerfix:feed:#{user.username}"
      user.shared_items.each do |share|
        f.entries << Atom::Entry.new do |e|
          e.title = share.title
          e.links << Atom::Link.new(:href => share.url)
          e.id = "readerfix:item:#{share.id}"
          e.updated = Time.parse(share.updated_at)
          e.summary = share.note || ""
        end
      end
    end.to_xml
  end
end