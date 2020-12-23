class BlinkAnalyzer
  private getter csv : Hash(String, Array(String))

  private BLINK_ACTION_UNIT_INDEX = "AU45_r" # https://en.wikipedia.org/wiki/Facial_Action_Coding_System

  def initialize(feature_extraction_analysis_dir : String) : Nil
    feature_extraction_csv = "#{feature_extraction_analysis_dir.split('/').last}.csv"

    # This leads the CSV into a hash where the key is the column name and the value is that column.
    # This isn't ideal, because it loads the entire CSV into memory, and duplicates the column headers,
    # so it could be rough on memory for really big CSVs. I did this for now, because the Crystal CSV
    # API is really barebones and difficult to work with.
    @csv = {} of String => Array(String)
    File.open(File.join(feature_extraction_analysis_dir, feature_extraction_csv)) do |csv|
      csv = CSV.new(csv, headers: true)
      headers = csv.headers
      csv.each do |row|
        headers.each do |header|
          @csv[header] ||= [] of String
          @csv[header].push(row[header])
        end
      end
    end
  end

  def analyze : Nil
    log("ANALYSIS:")
    log("Total blinks: #{total_blinks}")
    log("Length: #{video_length} minutes")
    log("Blinks / minute: #{total_blinks / video_length}")
  end

  private def total_blinks : Int32
    blinks = 0
    currently_blinking = false

    csv[BLINK_ACTION_UNIT_INDEX].each do |val|
      au = val.strip.to_f
      if currently_blinking && au == 0.0
        currently_blinking = false
      elsif !currently_blinking && au > 0.0
        currently_blinking = true
        blinks += 1
      end
    end

    blinks
  end

  private def video_length : Float64
    csv["timestamp"].last.to_f / 60
  end

  private def get_column(column_index : String) : Array(String)
    column : Array(String) = [] of String
    csv.each do |row|
      column << row[column_index].strip
    end
    column
  end
end
