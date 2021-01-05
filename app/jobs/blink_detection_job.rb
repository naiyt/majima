require "fileutils"

class BlinkDetectionJob < ApplicationJob
  queue_as :default

  def perform(video_id)
    video = Video.find(video_id)

    out_dir = BlinkDetection::FeatureExtraction.extract(video)
    BlinkDetection::FrameDumper.dump(video, out_dir)

    FileUtils.remove_dir(out_dir)

    video.update!(status: Video::PROCESSED)
  rescue => e
    video.update!(status: Video::ERRORED)

    raise e
  end
end
