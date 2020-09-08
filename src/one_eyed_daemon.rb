#!/usr/local/bin/ruby

require "listen"
require "./blink_detector.rb"

# TODO: spaces in the video filename breaks things
def run_detector(video_path)
  BlinkDetector.new(video_path, ARGV[0] == "true").detect # TODO: better command line args

  File.rename(video_path, File.join("video_out", video_path.split("/").last))
end

# Run for all the existing files once, before starting the listener
Dir["./video_in/*.mov", "./video_in/*.mkv", "./video_in/*.mp4"].each do |video|
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
