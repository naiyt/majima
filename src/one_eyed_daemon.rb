require "listen"
require "./blink_detector.rb"

def run_detector(video_path)
  BlinkDetector.new(video_path, ARGV[0] == "true").detect # TODO: better command line args

  # Delete the video to clean up after ourselves
  File.delete(video_path)
end

# Run for all the existing files once, before starting the listener
# TODO: support multiple video types
Dir["./video_in/*.mov"].each do |video|
  run_detector(video)
end

puts "[BLINK DETECTION] listening for new video files..."

listener = Listen.to("./video_in") do |_modified, added, _removed|
  added.each do |added_video|
    puts "[BLINK DETECTION] Detected new video, #{added_video}" # TODO: abstract the logger
    run_detector(added_video)
  end

  puts "[BLINK DETECTION] listening for new video files..." if added.any?
end
listener.start
sleep
