require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'

class GoogleAuthorizer
  CLIENT_SECRET_PATH = GoogleClientSecret.path
  attr_reader :auth_client

  def initialize
    @auth_client = load_auth_client
  end

  def authorize_uri
    auth_client.authorization_uri.to_s
  end

  def update_token!(user)
    auth_client.update!(refresh_token: user.refresh_token)
    auth_client.fetch_access_token!
    user.update!(access_token: auth_client.access_token) # not necessary
  end

  private

  def load_auth_client
    client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRET_PATH)
    client = client_secrets.to_authorization
    client.update!(
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
    )
    client
  end
end
