class AddStatusToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :status, :string, null: false
    add_index :videos, :status
  end
end
