class GoogleClientSecret
  cattr_reader :default_path do
    Rails.root.join("client_secret.json")
  end

  def self.path
    return default_path if File.exists?(default_path)

    new.create
  end

  def create
    File.write default_path, json_content
    default_path
  end

  def json_content
    {
      web: {
        client_id: ENV.fetch("GOOGLE_CLIENT_ID"),
        project_id: "gcal-booking-rails",
        auth_uri: "https:\/\/accounts.google.com\/o\/oauth2\/auth",
        token_uri: "https:\/\/accounts.google.com\/o\/oauth2\/token",
        auth_provider_x509_cert_url: "https:\/\/www.googleapis.com\/oauth2\/v1\/certs",
        client_secret: ENV.fetch("GOOGLE_CLIENT_SECRET"),
        redirect_uris: [
          ENV.fetch("GOOGLE_REDIRECT_URI")
        ]
      }
    }.to_json
  end
end
