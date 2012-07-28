require './environment'

HOOD_ID = "knssmocrdf01"

class Application < Sinatra::Base
  get '/' do
    @threshold = $redis.get("invites:threshold").to_i
    @active = $redis.get("invites:active").to_i
    
    erb :home
  end

  get '/fetch' do
    html = Faraday.get('https://fiber.google.com/cities/kcmo/').body
    json = html.match(/var hoodsById = (.*);$/i)[1]
    hoods = MultiJson.load(json)
    hood = hoods[HOOD_ID]

    $redis.set "invites:percent", hood["invite_percent"]
    $redis.set "invites:active", hood["invites"]
    $redis.set "invites:threshold", hood["invite_threshold"]
    $redis.set "invites:max", hood["max_invites"]

    content_type "text/plain"
    "OK"
  end
end