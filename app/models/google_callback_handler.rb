class GoogleCallbackHandler
  attr_reader :channel, :room, :user

  def initialize(google_channel)
    @channel = google_channel
    @room = google_channel.try(:room)
    @user = @room.try(:user)
  end

  def valid?
    !channel.nil? && !room.nil? && !user.nil?
  end

  def call
    return unless valid?

    events.items.each { |ei| GoogleEventHandler.new(ei, self).call }
  end

  private

  def auth_client
    @auth_client ||=
      begin
        auth = GoogleAuthorizer.new
        auth.update_token!(user)
        auth.auth_client
      end
  end

  def calendar
    @calendar ||= GoogleCalendar.new(user, auth_client)
  end

  def events
    @events ||=
      begin
        evs = calendar.events(channel.calendar_id, sync_token: channel.next_sync_token)
        channel.update!(next_sync_token: evs.next_sync_token)
        evs
      end
  end
end
