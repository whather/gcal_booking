class AlterResourceIdFromGoogleChannels < ActiveRecord::Migration[5.0]
  def change
    change_column :google_channels, :resource_id, :string, null: true
  end
end
