require 'spec_helper'
require 'rack/test'
require 'cgi'

require 'readerfix'
require 'user'

describe ReaderFix do
  include Rack::Test::Methods

  def app
    ReaderFix
  end

  let(:myurl) { "http://martenveldthuis.com/blog/2011-11-03-capistrano-colours" }
  let(:mytitle) { "capistrano-colors" }
  let(:mysource) { "geenidee" }
  let(:myshorturl) { "http://kort.ly" }
  let(:mynote) { "OHAI HIER EEN NOTE" }
  let(:querystring) do
    "source=#{CGI.escape(mysource)}" + 
    "&title=#{CGI.escape(mytitle)}" + 
    "&url=#{CGI.escape(myurl)}" + 
    "&shorturl=#{CGI.escape(myshorturl)}" +
    "&note=#{CGI.escape(mynote)}"
  end

  it "should be able to post a share" do
    get "/username/token/share?" + querystring
    last_response.should be_ok

    share = User.by_username("username").shared_items[0]
    share.url.should == myurl
    share.title.should == mytitle
    share.source.should == mysource
    share.shorturl.should == myshorturl
  end

  it "should show a form when sharing with a note" do
    get "/username/token/note?" + querystring
    last_response.should be_ok
    last_response.body.should include("<html")
    last_response.body.should include("<form")
  end

  it "should not be able to post with a false token" do
    get "/username/righttoken/share?" + querystring # create a user by making a post
    get "/username/wrongtoken/share?" + querystring
    last_response.should_not be_ok
  end

  it "should have an rss feed for a user" do
    get "/username/token/share?" + querystring
    get '/username.xml'
    last_response.body.should include('<feed xmlns="http://www.w3.org/2005/Atom">')
    last_response.body.should include(mytitle)
    last_response.body.should include(mynote)
  end
end