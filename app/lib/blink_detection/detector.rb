require "open3"

module BlinkDetection
  module Detector
    def self.detect(video)
      out_dir = Rails.root.join("tmp", video.video_file.key)

      switches = ["-f #{video.file_path}", "-out_dir #{out_dir}", "-aus"]

      cmd = "#{ENV["OPENFACE_EXECUTABLE_PATH"]} #{switches.join(" ")}"

      Rails.logger.info("Running cmd #{cmd}")

      start = Time.now

      Open3.popen3(cmd) do |_stdin, stdout, stderr, _thread|
        while (line = (stdout.gets || stderr.gets))
          Rails.logger.info(line)
        end
      end

      Rails.logger.info("Feature extraction execution time: #{(Time.now - start)}s")
      Rails.logger.info("FeatureExtraction analysis file written to #{out_dir}")

      out_dir
    end
  end
end
