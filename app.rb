require './environment'

class Application < Sinatra::Base
  get '/' do
    @threshold = $redis.get("invites:threshold").to_i
    @active = $redis.get("invites:active").to_i

    erb :home
  end
end