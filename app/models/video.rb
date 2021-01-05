class Video < ApplicationRecord
  has_one_attached :video_file
  has_many :frames, dependent: :destroy

  validates_presence_of :video_file, :started_recording_at

  def file_path
    ActiveStorage::Blob.service.path_for(video_file.key)
  end

  def start_blink_detection_job
    BlinkDetectionJob.perform_later(id)
  end
end
