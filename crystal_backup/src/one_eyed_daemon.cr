require "./blink_detector.cr"
require "./blink_analyzer.cr"
require "./logger.cr"

def run_daemon
  log("Waiting for video files...")

  file_types = ["*.mov", "*.mkv", "*.mp4", "*.webm"]
  file_paths = file_types.map { |type| File.join(ENV["MAJIMA_PATH"], "data", "video_in", type) }

  loop do
    Dir[file_paths].each do |video_path|
      log("Running OpenFace FeatureExtraction on #{video_path}")
      feature_extraction_analysis_dir = BlinkDetector.detect(video_path)

      log("Running analysis on the OpenFace FeatureExtraction written to #{feature_extraction_analysis_dir}")
      BlinkAnalyzer.new(feature_extraction_analysis_dir).analyze

      video_name = video_path.split("/").last
      new_path = File.join(ENV["MAJIMA_PATH"], "data", "video_out", video_name)
      log("Moving #{video_name} to #{new_path}")
      File.rename(video_path, new_path)
    end

    sleep 2.seconds
  end
end

if ENV["ANALYZE"]?
  path = File.join(ENV["MAJIMA_PATH"], "data", "analysis_out", ENV["ANALYZE"])

  log("Running analysis on the OpenFace FeatureExtraction in #{path}")
  BlinkAnalyzer.new(path).analyze
else
  run_daemon
end
