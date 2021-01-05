class RenameAuColumns < ActiveRecord::Migration[6.1]
  def change
    rename_column :frames, :AU45_c, :au45_c
    rename_column :frames, :AU45_r, :au45_r
  end
end
