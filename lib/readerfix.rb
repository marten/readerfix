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
    <<-END
      <!DOCTYPE html>
      <html itemscope itemtype="http://schema.org/Webapp">
      <title>ReaderFix</title>
      <meta itemprop="name" content="ReaderFix">
      <meta itemprop="description" content="This site re-enables sharing in Google Reader, so you can go back to ignoring Google+.">

      <body style="background: black; color: #0f0; font-size: 1.5em">
      <pre>


      Hallo. Welkom op onze mooie site.

      Google Reader haalt sharing weg, wij geven het terug!

      Om dit te gebruiken, moet je in Google Reader een "Send To" ding maken.  De URL die google reader wil is:

      http://#{request.host}/MIJNUSERNAME/VETGEHEIMTOKEN/share?source=${source}&title=${title}&url=${url}&shorturl=${short-url}

      Als dat gelukt is kun je je vrienden op deze URL laten abonneren:

      http://#{request.host}/MIJNUSERNAME.xml

      Vervolgens klik je bij toffe dingen in reader op Send To -> ReaderFix.


      !!! Deze dienst is nog experimenteel, noem het een publieke alpha of zo. Dit betekent dat shit
      !!! gewoon kan verdwijnen. Als het wat wordt verplaatsen we 'm bovendien misschien wel.
      !!! Dan moet je je configuratie van Reader misschien aanpassen (maar dan gooien we
      !!! wel een berichtje in je feed).


                                              Groetjes,

                                                Mark & Marten
                                                Deelbroertjes



      PS. Het token VETGEHEIMTOKEN is dat niet meer. Misschien wil je een andere.
      </pre>


      <g:plusone size="tall"></g:plusone>
      <script type="text/javascript">
        (function() {
          var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
          po.src = 'https://apis.google.com/js/plusone.js';
          var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
        })();
      </script>
    END
  end

  get '/:username/:token/share' do
    user   = User.by_username(params[:username])
    user ||= User.create(params.hash_from(:username, :token))

    raise "HACKER" unless user.validate_token(params[:token])

    user.share!(params.hash_from(:url, :title, :source, :shorturl))

    <<-END
    <script>
    window.close()
    </script>
    
    You share has been saved. This window should have self-destructed.
    END
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
          e.summary = "Voor de body moet je nog even doorklikken. Maar dat moest op Google+ ook. Het verschil is dat wij wel plannen hebben om dit te verbeteren."
        end
      end
    end.to_xml
  end
end