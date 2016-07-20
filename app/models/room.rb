class Room < ApplicationRecord
  belongs_to :user
  has_many :bookings

  enum price_unit: %i(min hour day month year)

  validates :name, presence: true
  validates :open_at, :close_at, presence: true
  validates :price, presence: true,
    numericality: { only_integer: true },
    inclusion: { in: 0..20_000 }
  validates :price_unit, presence: true
  validate :validate_opening_time

  private

  def validate_opening_time
    return if open_at <= close_at
    errors.add(:close_at, 'must be bigger than :open_at')
  end
end
