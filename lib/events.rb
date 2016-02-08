require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

module Events
  OOB_URI = 'https://lljbsfeqaq.localtunnel.me/oauth2callback'
  APPLICATION_NAME = 'Intercom interview'
  CLIENT_SECRETS_PATH = './lib/client_secret.json'
  CREDENTIALS_PATH = "./lib/google_credentials.yaml"
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # return credentials if options[:code] is given and valid
  # otherwise, return a redirect uri
  def self.google_calendar_credentials(options={})
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