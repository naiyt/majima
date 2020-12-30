class BlinkAnalyzer
  private getter csv : Hash(String, Array(Float64)), feature_extraction_analysis_dir : String
  @time_on_camera : Float64?
  @blink_lengths : Array(Float64)?

  private BLINK_ACTION_UNIT_INDEX = "AU45_r" # https://en.wikipedia.org/wiki/Facial_Action_Coding_System
  private MAX_BLINK_LENGTH        =   2      # Past this, and your eyes are probably just closed
  private MIN_BLINK_LENGTH        =   0
  private ACTION_UNIT_LOWER_BOUND = 0.2

  def initialize(@feature_extraction_analysis_dir : String) : Nil
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
    analysis = {
      "Total blinks":           total_blinks,
      "Length":                 "#{video_length}s",
      "Time on camera":         "#{time_on_camera}s, Time off camera: #{video_length - time_on_camera}s",
      "Blinks / minute":        "#{blinks_per_minute}",
      "Average Blink":          "#{average_blink_length}",
      "Median Blink":           "#{median_blink_length}",
      "Blink Length Std. Dev.": "#{stddev_blink_length}",
      "Longest Blink":          "#{longest_blink}",
      "Shorted Blink":          "#{shortest_blink}",
    }

    log("ANALYSIS:")

    File.open(File.join(feature_extraction_analysis_dir, "analysis.txt"), "w") do |f|
      analysis.each do |k, v|
        str = "#{k}: #{v}"
        f << str + "\n"
        log(str)
      end
    end
  end

  private def total_blinks : Int32
    blink_lengths.size
  end

  private def blink_lengths : Array(Float64)
    @blink_lengths ||= begin
      blinks = [] of Float64

      currently_blinking = false
      start_timestamp = 0.0

      csv[BLINK_ACTION_UNIT_INDEX].each_with_index do |au, i|
        if currently_blinking && au < ACTION_UNIT_LOWER_BOUND
          currently_blinking = false
          blinks << csv["timestamp"][i - 1] - start_timestamp
        elsif !currently_blinking && au >= ACTION_UNIT_LOWER_BOUND
          currently_blinking = true
          start_timestamp = csv["timestamp"][i]
        end
      end

      blinks.select { |b| b > MIN_BLINK_LENGTH && b < MAX_BLINK_LENGTH }
    end
  end

  private def average_blink_length : Float64
    blink_lengths.sum / blink_lengths.size
  end

  private def median_blink_length : Float64
    blink_lengths.sort[(blink_lengths.size / 2).to_i]
  end

  private def stddev_blink_length : Float64
    average = average_blink_length
    deviations = blink_lengths.map { |l| (l - average) ** 2 }
    Math.sqrt(deviations.sum / deviations.size)
  end

  private def longest_blink : Float64
    blink_lengths.max
  end

  private def shortest_blink : Float64
    blink_lengths.min
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
