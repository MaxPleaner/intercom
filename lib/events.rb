module Events
  # Google Calendar config
  OOB_URI = 'https://maxp-intercom.herokuapp.com/oauth2callback'
  #         This needs to be added as a "redirect URI" on the Google Developer console
  #         and lib/client_secret.json needs to be redownloaded/updated whenever it changes.
  #         The "oauth2callback" route was not a deliberate choice; it is google's default
  APPLICATION_NAME = 'Intercom interview'
  CLIENT_SECRETS_PATH = './lib/client_secret.json'
  CREDENTIALS_PATH = "./lib/google_credentials.yaml" # File gets created automatically
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR # read-write scope

  # return credentials if options[:code] is given and valid
  # otherwise, return a redirect uri
  def self.google_calendar_credentials(options={})
    # giving credit where due (the google example code) - https://developers.google.com/google-apps/calendar/quickstart/ruby
    # This app does not implement the entire OAuth2 flow, though ... only the initial confirmation is used,
    # The resultant access / refresh tokens arent used. 
    FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
    client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store)
    if options[:code]
      return authorizer.get_and_store_credentials_from_code(
        user_id: "intercom_user", code: options[:code], base_url: OOB_URI)
    else
      return authorizer.get_authorization_url(
        base_url: OOB_URI, scope: "https://www.googleapis.com/auth/calendar")
    end
  end
  
end