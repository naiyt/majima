require "csv"

class BlinkDetector
  getter video_path

  def initialize(@video_path : String) : Nil
  end

  def detect : Nil
    log("Running OpenFace FeatureExtraction on #{video_path}")
    feature_extraction_analysis_dir = run_openface_feature_extraction
    compute_blinks(feature_extraction_analysis_dir)
  end

  # TODO: these absolute paths shouldn't be hardcoded like this, too dependent on the Docker setup
  private FEATURE_EXTRACTION_PATH = "/home/openface-build/build/bin/FeatureExtraction"
  private OUTDIR_PATH             = "/home/majima/data/analysis_out"
  private BLINK_ACTION_UNIT_INDEX = "AU45_r" # https://en.wikipedia.org/wiki/Facial_Action_Coding_System

  private def run_openface_feature_extraction : String
    video_name = video_path.split("/").last.split(".").first
    out_dir = [OUTDIR_PATH, video_name].join("/")

    switches = [
      "-f #{video_path}",
      "-out_dir #{out_dir}",
      "-aus",
    ]

    log("Running cmd #{FEATURE_EXTRACTION_PATH} #{switches.join(' ')}")

    output = `#{FEATURE_EXTRACTION_PATH} #{switches.join(' ')}`
    puts output
    # TODO: This freeses after reading the triangulation? It would be preferable to use something like this, to stream the output
    # reader, writer = IO.pipe
    # Process.run(FEATURE_EXTRACTION_PATH, switches, shell: true, output: writer) do |process|
    #   until process.terminated?
    #     line = reader.gets
    #     puts line
    #   end
    # end

    log("FeatureExtraction analysis file written to #{out_dir}")

    out_dir
  end

  private def compute_blinks(feature_extraction_analysis_dir : String) : Nil
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

  private def log(str : String) : Nil
    puts "[BLINK DETECTOR] #{str}"
  end
end

# TODO: listen functionality, like I had in Ruby?
Dir[
  "/home/majima/data/video_in/*.mov",
  "/home/majima/data/video_in/*.mkv",
  "/home/majima/data/video_in/*.mp4",
].each do |video|
  BlinkDetector.new(video).detect
end
