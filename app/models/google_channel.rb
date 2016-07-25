class GoogleChannel < ApplicationRecord
  belongs_to :room

  validates :channel_id,  presence: true, uniqueness: true
  validates :calendar_id, presence: true
  validates :resource_id, presence: true
end
