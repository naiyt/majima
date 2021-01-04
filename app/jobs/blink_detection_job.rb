class BlinkDetectionJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    BlinkDetection::Detector.detect(Video.find(video_id))
  end
end
