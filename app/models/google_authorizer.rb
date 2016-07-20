require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets'

class GoogleAuthorizer
  CLIENT_SECRET_PATH = GoogleClientSecret.path
  attr_reader :auth_client

  def initialize
    client_secrets = Google::APIClient::ClientSecrets.load(CLIENT_SECRET_PATH)
    @auth_client = client_secrets.to_authorization
  end

  def authorize_uri
    @authorize_uri ||=
      begin
        auth_client.update!(
          scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
        )
        auth_client.authorization_uri.to_s
      end
  end
end
