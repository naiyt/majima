require "./blink_detector.cr"
require "./logger.cr"

file_types = ["*.mov", "*.mkv", "*.mp4"]
file_paths = file_types.map { |type| File.join(ENV["MAJIMA_PATH"], "data", "video_in", type) }

loop do
  Dir[file_paths].each do |video_path|
    BlinkDetector.new(video_path).detect

    video_name = video_path.split("/").last
    new_path = File.join(ENV["MAJIMA_PATH"], "data", "video_out", video_name)
    log("Moving #{video_name} to #{new_path}")
    File.rename(video_path, new_path)
  end

  sleep 2.seconds
end
