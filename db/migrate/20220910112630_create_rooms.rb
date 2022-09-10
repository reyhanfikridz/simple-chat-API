class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.string :name, limit: 250, null: true
      t.string :type, limit: 15, null: false

      t.timestamps
    end
  end
end
