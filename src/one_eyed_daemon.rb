require "./blink_detector.rb"

# TODO: support multiple video types
Dir["./video_in/*.mov"].each do |video|
  BlinkDetector.new(video).detect
end
