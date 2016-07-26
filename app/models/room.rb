class Room < ApplicationRecord
  belongs_to :user
  has_many :bookings
  has_many :google_channels

  enum price_unit: %i(min hour day month year)

  validates :name, presence: true
  validates :open_at, :close_at, presence: true
  validates :price, presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..20_000 }
  validates :price_unit, presence: true
  validate :validate_opening_time

  # resource_id nil true
  def sync(calendar_id)
    # TODO: check user.refresh_token and raise error
    cal = GoogleCalendar.new(user, authorizer.auth_client)
    channel = cal.watch_events(calendar_id)

    gc = google_channels.find_or_initialize_by(
      calendar_id: calendar_id,
      resource_id: channel.resource_id,
    )
    gc.update!(
      channel_id: channel.id,
      expired_at: Time.zone.at(channel.expiration.to_i),
    )
  end

  private

  def validate_opening_time
    return if open_at <= close_at
    errors.add(:close_at, 'must be bigger than :open_at')
  end

  def authorizer
    @authorizer ||=
      begin
        a = GoogleAuthorizer.new
        a.update_token!(user)
        a
      end
  end
end
