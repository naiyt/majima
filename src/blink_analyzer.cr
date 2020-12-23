class BlinkAnalyzer
  private getter csv : Hash(String, Array(Float64))
  @time_on_camera : Float64?
  @total_blinks : Int32?

  private BLINK_ACTION_UNIT_INDEX = "AU45_r" # https://en.wikipedia.org/wiki/Facial_Action_Coding_System

  def initialize(feature_extraction_analysis_dir : String) : Nil
    feature_extraction_csv = "#{feature_extraction_analysis_dir.split('/').last}.csv"

    # This leads the CSV into a hash where the key is the column name and the value is that column.
    # This isn't ideal, because it loads the entire CSV into memory, and duplicates the column headers,
    # so it could be rough on memory for really big CSVs. I did this for now, because the Crystal CSV
    # API is really barebones and difficult to work with.
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

      first_success_index = 0
      csv["success"].each_with_index do |success, index|
        if success
          first_success_index = index
          break
        end
      end

      start_timestamp = csv["timestamp"][first_success_index]
      currently_on_camera = true

      csv["timestamp"][first_success_index + 1..].each_with_index do |timestamp, i|
        if currently_on_camera && csv["success"][i] != 1.0
          end_timestamp = csv["timestamp"][i - 1]
          time += end_timestamp - start_timestamp
          currently_on_camera = false
        elsif !currently_on_camera && csv["success"][i] == 1.0
          start_timestamp = timestamp
          currently_on_camera = true
        end
      end

      if csv["success"][-1] == 1.0
        end_timestamp = csv["timestamp"][-1]
        time += end_timestamp - start_timestamp
      end

      time
    end
  end
end
