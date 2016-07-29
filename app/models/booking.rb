class Booking < ApplicationRecord
  belongs_to :room

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :google_resource_id, uniqueness: true
  validate :validate_time, on: [:create, :update]

  scope :in_between, -> (start_at, end_at) {
    where(end_at: [start_at..end_at])
      .or(where(start_at: [start_at..end_at]))
  }

  private

  def validate_time
    return if start_at <= end_at
    errors.add(:end_at, 'must be greater than :start_at')
  end
end
