# intercom
a coding challenge for Intercom

This is a Sinatra app using ActiveRecord and Postgres. It is hosted on Heroku.

The source code is commented and is hopefully self-documenting.

In summary ...
- There is a page which says my "proudest accomplishment"
- There is a page which implements a distance-filter on customer records. It displays this filter using Google Maps.
- There is a page which imports events into Google Calendar (using oAuth2) and displays the user's upcoming events.

Here's an outline of the files:
- `Gemfile`: dependencies
- `config.ru`: intructions for how heroku should start the app
  - includes a couple plugins ... SSL forcing and basic HTTP auth
- `.gitignore`: everything is on git except `.env`, `lib/google_credentials.yaml` and `lib/client_secrets.json`. With postgres there's no need to ignore the db.
- `.env.example`: a template for `.env`, which  sets environment variables for basic HTTP auth and Google API credentials
- `server.rb`: **the core of the app**, includes model definitions and routes
- `lib/client_secret.json.example`: template for `lib/client_secret.json`, which is the Google credentials downloaded from their developer console
- `lib/customers.txt`: the source for customers, taken from the challenge prompt gist. The app coerces this data into JSON.
- `lib/events.rb`: uses Google Calendar to import / display some events.
- `lib/google_credentials.yaml`: isn't present in source control, created by the app when it is running. 
- `lib/proudest_achievement.rb`: some text about my achievement(s)
- `lib/seed_events.rb`: source for the events which are imported to Google Calendar. These are taken from the challenge prompt gist.
- `lib/user_locator.rb`: uses Google Maps and the geocoder gem to implement a distance filter. 
- `views/import_events.erb`: HTML page for the Events section of the app
- `views/layout.erb`: the application layout, used by all the HTML pages
- `views/proudest_achievement.rb`: HTML page for my achievement(s)
- `views/root.erb`: HTML for the `"/"` (root) route, links to the other pages
- `views/user_locator.erb`: HTML page for the distance-filter section
- `views/user_locator_map.erb`: Javascript / HTML code for Google Maps
