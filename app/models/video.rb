class Video < ApplicationRecord
  has_one_attached :video_file

  def file_path
    ActiveStorage::Blob.service.path_for(video_file.key)
  end

  def start_blink_detection_job
    BlinkDetectionJob.perform_later(id)
  end
end
