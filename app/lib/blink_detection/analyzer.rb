module BlinkDetection
  class Analyzer
    def initialize(video)
      @video = video
    end

    def video_length
      @video_length ||= frames.last.timestamp
    end

    def blinks
      @blinks ||=
        begin
          blinks = []

          currently_blinking = false
          start_timestamp = 0.0

          frames
            .map(&:au45_r)
            .each_with_index do |au, i|
              if currently_blinking && au < ACTION_UNIT_LOWER_BOUND
                currently_blinking = false
                blinks << frames[i - 1].timestamp - start_timestamp
              elsif !currently_blinking && au >= ACTION_UNIT_LOWER_BOUND
                currently_blinking = true
                start_timestamp = frames[i].timestamp
              end
            end

          blinks.select { |b| b > MIN_BLINK_LENGTH && b < MAX_BLINK_LENGTH }
        end
    end

    def time_on_camera
      @time_on_camera ||=
        begin
          time = 0.0

          # Find the first frame in which a face is on the camera
          first_success_index = (0...frames.count).find { |i| frames[i].success }

          return 0 if first_success_index.nil?

          # Extract and add up each subsection where a face is actually on camera
          start_timestamp = frames[first_success_index].timestamp
          currently_on_camera = true

          frames[first_success_index + 1..].each_with_index do |frame, i|
            i += first_success_index + 1

            if currently_on_camera && !frame.success
              time += frames[i - 1].timestamp - start_timestamp
              currently_on_camera = false
            elsif !currently_on_camera && frame.success
              start_timestamp = frame.timestamp
              currently_on_camera = true
            end
          end

          # Clean up the final subsection, if the video ended with us still on camera
          time += frames[-1].timestamp - start_timestamp if frames[-1].success

          time
        end
    end

    def average_blink_length
      return 0 if blinks.size == 0
      blinks.sum / blinks.size
    end

    def median_blink_length
      blinks.sort[(blinks.size / 2).to_i]
    end

    def stddev_blink_length
      return 0 if blinks.size == 0
      average = average_blink_length
      deviations = blinks.map { |l| (l - average)**2 }
      Math.sqrt(deviations.sum / deviations.size)
    end

    def longest_blink
      blinks.max
    end

    def shortest_blink
      blinks.min
    end

    def blinks_per_minute
      return 0 if time_on_camera == 0
      blinks.length / (time_on_camera / 60)
    end

    def frames
      @frames ||= video.frames.order(:frame).to_a
    end

    private

    attr_reader :video

    MAX_BLINK_LENGTH = 1
    MIN_BLINK_LENGTH = 0
    ACTION_UNIT_LOWER_BOUND = 0.2
  end
end
