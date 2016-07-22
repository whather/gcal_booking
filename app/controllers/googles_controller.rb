class GooglesController < ApplicationController
  before_action :authenticate_user!

  def callback
    load_gauth
    @gauth.auth_client.code = params[:code]
    @gauth.auth_client.fetch_access_token!
    current_user.update!(
      access_token: @gauth.auth_client.access_token,
      refresh_token: @gauth.auth_client.refresh_token,
    )

    render text: "success!"
  end

  def authorize
    load_gauth
    redirect_to @gauth.authorize_uri
  end

  private

  def load_gauth
    @gauth = GoogleAuthorizer.new
  end
end
