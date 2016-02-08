require 'json'
require 'sinatra'
require 'sinatra/multi_route'
require 'active_support/core_ext/string'
require 'awesome_print'
require 'colored'
require 'dotenv'
require 'rack-ssl-enforcer'

require "./lib/proudest_achievement.rb"
require "./lib/user_locator.rb"
require "./lib/events.rb"
require './lib/seed_events.rb'

Dotenv.load # sets environment variables from .env file

# No command line arguments are accepted
# Do this to ensure that they don't interfere with "gets"
raise(StandardError, "No command line arguments are accepted") unless ARGV.blank?

include ERB::Util # defines an "h" method akin to rails' "raw"
                  # for printing unescaped html

# variables used for basic HTTP auth
# loaded from the .env file
basic_auth_username = ENV["BASIC_AUTH_USERNAME"]
basic_auth_password = ENV["BASIC_AUTH_PASSWORD"]
unless [basic_auth_username, basic_auth_password].all?
  raise(StandardError, "Env Vars not set") 
end

# Customers.txt doesnt appear to be in a standard
# data-serialization format, but it can be turned into JSON easily.
def parse_customers_as_json
  JSON.parse(
    "[" + File.readlines("./lib/customers.txt").reject(&:blank?).join(", ") + "]"
  )
end

# This is required for the user_locator route
# Ensures that the necessary environment variable is set
# The variable should be defined in the .env file
until ENV["GOOGLE_MAPS_API_KEY"]
  puts "\n\nThe GOOGLE_MAPS_API_KEY environment variable needs to be set.\n\n".black_on_white
  raise(StandardError, "Environment variable not set")
end

# This is required for the events route
# Ensures that the necessary environment variable is set
# The variable should be defined in the .env file
until ENV["GOOGLE_CALENDAR_API_KEY"]
  puts "\n\nThe GOOGLE_CALENDAR_API_KEY environment variable needs to be set.\n\n".black_on_white
  raise(StandardError, "Environment variable not set")
end

puts "The server will now run. Go to localhost:4567 in the browser".yellow_on_black

puts "\n***** Routes ***** \n".red_on_black

puts "get '/' => views/root.erb\n".yellow_on_black
get "/" do
  erb :root
end

puts "get '/user_locator' => views/user_locator.erb\n".yellow_on_black
get "/user_locator" do
  @distance = params[:distance] || 100
  @customers = UserLocator.active_record_geocoder(customers: parse_customers_as_json, distance: @distance.to_i)
  @excluded_users = UserLocator::Customer.where("id NOT in (?)", @customers.pluck(:id))
  erb :user_locator
end

puts "get '/proudest_achievement' => views/proudest_achievement.erb\n".yellow_on_black
get "/proudest_achievement" do
  @proudest_achievement = ProduestAchievement # see lib/proudest_achievement.rb
  erb :proudest_achievement
end

puts "get '/import_events' => views/import_events.erb"
get "/import_events", "/events" do
  @message = params[:message]
  if params[:google_calendar_auth_code].blank?
    @google_auth_confirmation_uri = Events.google_calendar_credentials
    # show the (external) authorization link on the HTML page
  else
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = Events::APPLICATION_NAME
    begin
      service.authorization = Events.google_calendar_credentials(code: params[:google_calendar_auth_code])
    rescue Signet::AuthorizationError => e
      # Error is produced when the user triggers a refresh on this page
      # In response, have them authorize again
      redirect to("import_events?message=#{URI.escape("Please authenticate again")}")
    end
    calendar_id = 'primary' # use the default namespace for events on Google Calendar
    # create events
    @new_events = SeedEvents.map do |event| # see lib/seed_events.rb
      service.insert_event( calendar_id, Google::Apis::CalendarV3::Event.new(
        summary: event[:occasion],
        description: event.ai(html: true),
        attachments: [],
        attendes: [],
        reminders: nil,
        start: Google::Apis::CalendarV3::EventDateTime.new(date: "#{event[:year]}-#{event[:month]}-#{event[:day]}"),
        end: Google::Apis::CalendarV3::EventDateTime.new(date: "#{event[:year]}-#{event[:month]}-#{event[:day]}"),
      ))
    end
    # list events
    calendar_events = service.list_events(calendar_id,
                                   max_results: 1000,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_min: Time.now.iso8601)
    @events = (calendar_events.try(:items) || []).map do |event|
      {
        description: event.description,
        creator: event.creator,
        html_link: event.html_link,
        start_time: event.start.date_time,
        end_time: event.end.date_time,
      }
    end
  end
  erb :import_events
end

get "/oauth2callback" do # called by Google
  redirect to("/import_events?google_calendar_auth_code=#{params[:code]}")
end

puts "*******************\n".red_on_black

