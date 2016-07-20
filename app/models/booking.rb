class Booking < ApplicationRecord
  belongs_to :room

  validates :start_at, presence: true
  validates :end_at, presence: true
  validate :validate_time

  private

  def validate_time
    return if start_at <= end_at
    errors.add(:end_at, 'must be greater than :start_at')
  end
end
