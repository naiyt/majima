class Video < ApplicationRecord
  has_one_attached :video_file
  has_many :frames, dependent: :destroy

  PROCESSING = "processing".freeze
  PROCESSED = "processed".freeze
  ERRORED = "errored".freeze

  VALID_STATUSES = [PROCESSING, PROCESSED, ERRORED].freeze

  validates_inclusion_of :status, in: VALID_STATUSES
  validates_presence_of :video_file, :started_recording_at

  def file_path
    ActiveStorage::Blob.service.path_for(video_file.key)
  end

  def start_blink_detection_job
    BlinkDetectionJob.perform_later(id)
  end

  def analyzer
    @analyzer ||= BlinkDetection::Analyzer.new(self)
  end
end
