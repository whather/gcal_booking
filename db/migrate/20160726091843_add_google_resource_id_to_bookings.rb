class AddGoogleResourceIdToBookings < ActiveRecord::Migration[5.0]
  def change
    add_column :bookings, :google_resource_id, :string
    add_index :bookings, :google_resource_id, unique: true
  end
end
