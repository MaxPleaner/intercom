
This is a Sinatra app using ActiveRecord and Postgres. It is hosted on Heroku.

The source code is commented and is hopefully self-documenting.

It was build as a coding challenge to a company. 

In summary ...
- There is a page which says my "proudest accomplishment"
- There is a page which implements a distance-filter on customer records (sorting customers by proximity to a central location). It displays this filter using Google Maps.
- There is a page which imports events into Google Calendar (using oAuth2) and displays the user's upcoming events.

Here's an outline of the files:
- `Gemfile`: dependencies
- `config.ru`: intructions for how heroku should start the app
  - includes a couple plugins ... SSL forcing and basic HTTP auth
- `.gitignore`: everything is on git except `.env`, `lib/customers.txt`, `lib/google_credentials.yaml` and `lib/client_secrets.json`. With postgres there's no need to ignore the db.
- `.env.example`: a template for `.env`, which  sets environment variables for basic HTTP auth and Google API credentials
- `server.rb`: **the core of the app**, includes model definitions and routes
- `lib/customers.txt`: the source for customers, taken from the challenge prompt gist. The app coerces this data into JSON. Not included in source control, to respect data privacy
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

Steps needed to run locally:
- install postgres, create a postgres database with the name specified in server.rb i.e. `localhost/mydb3`
- Set up google developers account, enable Calendar and Maps APIs.
  - For Maps, just get the API key
  - for Calendar, set up as oAuth2 provider. Make sure to set the redirect uri to `ROOT_URL/oauth2callback` and it is the same as `Events::OOB_URI`. Download the credentials into `lib/client_secret.json`.
- download the customers.txt file (from the challenge prompt gist) into `lib/customers.txt`
- `bundle` and `rackup`.


---
