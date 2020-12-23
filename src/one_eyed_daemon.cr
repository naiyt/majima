require "./blink_detector.cr"

file_types = ["*.mov", "*.mkv", "*.mp4"]
file_paths = file_types.map { |type| File.join(ENV["MAJIMA_PATH"], "data", "video_in", type) }

loop do
  Dir[file_paths].each do |video_path|
    BlinkDetector.new(video_path).detect
    File.rename(video_path, File.join(ENV["MAJIMA_PATH"], "data", "video_out", video_path.split("/").last))
  end

  sleep 2.seconds
end
