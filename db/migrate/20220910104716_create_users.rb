class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, limit: 100
      t.string :password, limit: 250
      t.string :full_name, limit: 250
      t.string :phone_number, limit: 20
      t.string :address, limit: 250

      t.timestamps
    end
  end
end
