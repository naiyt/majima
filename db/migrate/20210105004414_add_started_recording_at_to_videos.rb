class AddStartedRecordingAtToVideos < ActiveRecord::Migration[6.1]
  def change
    add_column :videos, :started_recording_at, :datetime, null: false, index: true
    add_index :videos, :started_recording_at
  end
end
