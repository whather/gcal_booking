class CreateRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :rooms do |t|
      t.references :user, index: true
      t.string :name, null: false, default: ""
      t.time :open_at, null: false
      t.time :close_at, null: false
      t.integer :price, null: false, default: 0
      t.integer :price_unit, null: false, default: 0

      t.timestamps
    end
  end
end
