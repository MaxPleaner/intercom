require "./server.rb"

# require login to use the site at all
use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == ENV["BASIC_AUTH_USERNAME"] and password == ENV["BASIC_AUTH_PASSWORD"]
end

# force SSL
use Rack::SslEnforcer

# run the Sinatra App
run Sinatra::Application