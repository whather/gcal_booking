class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def google_authorizer(user = nil)
    return if user.nil? && !user_signed_in?
    return if !(user || current_user).refresh_token?

    @google_authorizer ||=
      begin
        auth = GoogleAuthorizer.new
        auth.update_token!(user || current_user)
        auth
      end
  end

  def calendar_list
    return [] unless google_authorizer

    gcal = GoogleCalendar.new(current_user, google_authorizer.auth_client)
    gcal.calendar_list
  end
end
