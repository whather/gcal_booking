class CreateGoogleChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :google_channels do |t|
      t.string :channel_id, null: false, default: ""
      t.references :room, index: true, null: false
      t.string :calendar_id, null: false, default: ""
      t.string :resource_id, null: false, default: ""
      t.datetime :expired_at

      t.timestamps
    end
    add_index :google_channels, :channel_id, unique: true
  end
end
