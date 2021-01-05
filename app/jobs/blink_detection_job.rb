class BlinkDetectionJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find(video_id)

    BlinkDetection::Detector.detect(video)

    video.update!(status: Video::PROCESSED)
  rescue => e
    video.update!(status: Video::ERRORED)

    raise e
  end
end
