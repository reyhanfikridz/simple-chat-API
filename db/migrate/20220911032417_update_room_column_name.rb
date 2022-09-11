class UpdateRoomColumnName < ActiveRecord::Migration[7.0]
  def change
    rename_column :rooms, :type, :flag
  end
end
