class BlinkAnalyzer
  private getter csv : Hash(String, Array(Float64))
  @time_on_camera : Float64?
  @total_blinks : Int32?

  private BLINK_ACTION_UNIT_INDEX = "AU45_r" # https://en.wikipedia.org/wiki/Facial_Action_Coding_System

  def initialize(feature_extraction_analysis_dir : String) : Nil
    feature_extraction_csv = "#{feature_extraction_analysis_dir.split('/').last}.csv"

    # This loads the CSV into a hash where the key is the column name and the value is that column.
    # This isn't ideal, because it loads the entire CSV into memory, and duplicates the column headers,
    # so it could be rough on memory for big CSVs. I did it this way (for now) because the Crystal CSV
    # API is really barebones and difficult to work with. Might have to refactor it if it becomes a memory
    # issue.
    @csv = {} of String => Array(Float64)
    File.open(File.join(feature_extraction_analysis_dir, feature_extraction_csv)) do |csv|
      csv = CSV.new(csv, headers: true)
      headers = csv.headers
      csv.each do |row|
        headers.each do |header|
          @csv[header] ||= [] of Float64
          @csv[header].push(row[header].strip.to_f)
        end
      end
    end
  end

  def analyze : Nil
    log("ANALYSIS:")
    log("Total blinks: #{total_blinks}")
    log("Length: #{video_length}s")
    log("Time on camera: #{time_on_camera}s, Time off camera: #{video_length - time_on_camera}s")
    log("Blinks / minute: #{blinks_per_minute}")
  end

  private def total_blinks : Int32
    @total_blinks ||= begin
      blinks = 0
      currently_blinking = false

      csv[BLINK_ACTION_UNIT_INDEX].each do |au|
        if currently_blinking && au == 0.0
          currently_blinking = false
        elsif !currently_blinking && au > 0.0
          currently_blinking = true
          blinks += 1
        end
      end

      blinks
    end
  end

  private def blinks_per_minute : Float64
    total_blinks / (time_on_camera / 60)
  end

  private def video_length : Float64
    csv["timestamp"].last.to_f
  end

  private def time_on_camera : Float64
    @time_on_camera ||= begin
      time = 0.0

      # Find the first frame in which a face is on the camera
      first_success_index = (0...csv["success"].size).find(0) { |i| csv["success"][i] == 1.0 }

      # Extract and add up each subsection where a face is actually on camera
      start_timestamp = csv["timestamp"][first_success_index]
      currently_on_camera = true

      csv["timestamp"][first_success_index + 1..].each_with_index do |timestamp, i|
        if currently_on_camera && csv["success"][i] != 1.0
          time += csv["timestamp"][i - 1] - start_timestamp
          currently_on_camera = false
        elsif !currently_on_camera && csv["success"][i] == 1.0
          start_timestamp = timestamp
          currently_on_camera = true
        end
      end

      # Clean up the final subsection, if the video ended with us still on camera
      time += csv["timestamp"][-1] - start_timestamp if csv["success"][-1] == 1.0

      time
    end
  end
end
