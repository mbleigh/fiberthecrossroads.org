require './environment'

HOOD_ID = ENV["HOOD_ID"] || "knssmocrdf01"

task :fetch do
  html = Faraday.get('https://fiber.google.com/cities/kcmo/').body
  json = html.match(/var hoodsById = (.*);$/i)[1]
  hoods = MultiJson.load(json)
  hood = hoods[HOOD_ID]

  $redis.set "invites:percent", hood["invite_percent"]
  $redis.set "invites:active", hood["invites"]
  $redis.set "invites:threshold", hood["invite_threshold"]
  $redis.set "invites:max", hood["max_invites"]
  $redis.set "info:last_fetched", Time.now.to_i

  puts "Fetched successfully at #{Time.now.to_s}"
end