class ChangeColumnTypes < ActiveRecord::Migration[6.1]
  def change
    change_column :frames, :confidence, :float
    change_column :frames, :au45_c, :float
    change_column :frames, :au45_r, :float

    add_index :frames, %i[frame video_id], unique: true
  end
end
