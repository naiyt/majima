class SetDefaultTimestampsForFrames < ActiveRecord::Migration[6.1]
  def change
    # Have Postgres handle created_at / update_at, so that upsert_all works
    change_column_default :frames, :created_at, -> { "CURRENT_TIMESTAMP" }
    change_column_default :frames, :updated_at, -> { "CURRENT_TIMESTAMP" }
  end
end
