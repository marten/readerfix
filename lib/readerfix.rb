require 'sinatra/base'
require_relative 'monkeypatches'
require_relative 'user'
require 'atom'

class ReaderFix < Sinatra::Base
  get '/:username/:token/share' do
    user   = User.by_username(params[:username])
    user ||= User.create(params.hash_from(:username, :token))

    raise "HACKER" unless user.validate_token(params[:token])

    user.share!(params.hash_from(:url, :title, :source, :shorturl))
  end

  get '/:username/rss.xml' do
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
          e.summary = "Some text."
        end
      end
    end.to_xml
  end
end