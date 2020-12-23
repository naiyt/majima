class BlinkAnalyzer
  getter feature_extraction_analysis_dir

  private BLINK_ACTION_UNIT_INDEX = "AU45_r" # https://en.wikipedia.org/wiki/Facial_Action_Coding_System

  def initialize(@feature_extraction_analysis_dir : String) : Nil; end

  def analyze : Nil
    feature_extraction_csv = "#{feature_extraction_analysis_dir.split('/').last}.csv"

    log("Computing blinks from #{feature_extraction_csv}")

    blink_action_units : Array(Float64) = [] of Float64

    File.open(File.join(feature_extraction_analysis_dir, feature_extraction_csv)) do |csv|
      CSV.new(csv, headers: true).each do |row|
        blink_action_units << row[BLINK_ACTION_UNIT_INDEX].strip.to_f
      end
    end

    blinks = 0
    currently_blinking = false

    blink_action_units.each do |au|
      if currently_blinking && au == 0.0
        currently_blinking = false
      elsif !currently_blinking && au > 0.0
        currently_blinking = true
        blinks += 1
      end
    end

    log("Number of blinks: #{blinks}")

    write_blink_analysis(feature_extraction_analysis_dir, blinks)
  end

  private def write_blink_analysis(dir, blinks)
    CSV.build(File.new(filename: File.join(dir, "blinks.csv"), mode: "w")) do |csv|
      csv.row ["blinks"]
      csv.row [blinks]
    end
  end
end
