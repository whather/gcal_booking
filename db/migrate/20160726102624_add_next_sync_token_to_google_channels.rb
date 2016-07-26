class AddNextSyncTokenToGoogleChannels < ActiveRecord::Migration[5.0]
  def change
    add_column :google_channels, :next_sync_token, :string
  end
end
