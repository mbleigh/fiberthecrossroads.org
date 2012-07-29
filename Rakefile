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
  $redis.set "info:last_modified", Time.now.to_i

  $redis.hset "stats", "total_available", hoods.values.inject(0){|total,hood| total += hood["max_invites"]}
  $redis.hset "stats", "total_threshold", hoods.values.inject(0){|total,hood| total += hood["invite_threshold"]}
  $redis.hset "stats", "total_active", hoods.values.inject(0){|total,hood| total += hood["invites"]}
  $redis.hset "stats", "total_hoods", hoods.size
  $redis.hset "stats", "active_hoods", hoods.values.select{|h| h["invites"] >= h["invite_threshold"]}.size

  hoods.values.each do |hood|
    $redis.zadd "stats:hood_goals", (hood["invite_ratio_target"] * 100), hood["name"]
    $redis.zadd "stats:rank", (hood["rank"]), hood["name"]
  end

  puts "Fetched successfully at #{Time.now.to_s}"
end