class CreateFrames < ActiveRecord::Migration[6.1]
  def change
    create_table :frames do |t|
      t.integer :frame, null: false
      t.integer :face_id, null: false
      t.float :timestamp, null: false
      t.integer :confidence, null: false
      t.boolean :success, null: false
      t.integer :AU45_r, null: false
      t.integer :AU45_c, null: false
      t.bigint :video_id, null: false

      t.timestamps
    end

    add_index :frames, :success
    add_index :frames, :AU45_r
    add_index :frames, :AU45_c
    add_index :frames, :video_id

    add_foreign_key :frames, :videos, on_delete: :cascade
  end
end
