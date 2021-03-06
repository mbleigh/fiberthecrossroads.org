require './environment'

require 'omniauth-twitter'
require 'omniauth-facebook'

class Application < Sinatra::Base
  register Sinatra::Flash

  use Rack::Session::Cookie
  use OmniAuth::Builder do
    provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
    provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  end

  helpers do
    def format_number(n)
      n.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
    end
  end

  get '/' do
    response['Cache-Control'] = 'public, max-age=600'
    etag $redis.get("info:last_modified")

    @threshold = $redis.get("invites:threshold").to_i
    @active = $redis.get("invites:active").to_i
    @users = $redis.lrange("users:list", 0, -1)

    erb :home
  end

  get '/stats' do
    response['Cache-Control'] = 'public, max-age=600'
    etag $redis.get("info:last_modified")

    @stats = $redis.hgetall("stats")

    erb :stats
  end

  get '/auth/:provider/callback' do
    auth_hash = request.env['omniauth.auth']
    provider = params[:provider]
    avatar_url = auth_hash.info.image

    user_hash = {
      name: auth_hash.info.name,
      image: avatar_url,
    }

    user_hash[:link] = "http://twitter.com/#{auth_hash.info.nickname}" if provider == 'twitter'

    unless $redis.sismember "users:set", "#{provider}:#{auth_hash.uid}"
      $redis.multi do
        $redis.sadd "users:set", "#{provider}:#{auth_hash.uid}"
        $redis.rpush "users:list", "#{provider}:#{auth_hash.uid}"
        $redis.hmset "users:#{provider}:#{auth_hash.uid}", *(user_hash.to_a.flatten)
        $redis.set "info:last_modified", Time.now.to_i.to_s
      end
    end

    session[:user] = "#{provider}:#{auth_hash.uid}"

    redirect '/'
  end
end