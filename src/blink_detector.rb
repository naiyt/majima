require "open3"
require "csv"
require "pry"
require "pry-nav"

class BlinkDetector
  def initialize(video_path)
    @video_path = video_path
  end

  def detect
    log("Running OpenFace FeatureExtraction on #{video_path}")
    feature_extraction_csv = run_openface_feature_extraction
    compute_blinks(feature_extraction_csv)
  end

  private

  attr_reader :video_path

  FEATURE_EXTRACTION_PATH = "/home/openface-build/build/bin/FeatureExtraction".freeze
  BLINK_ACTION_UNIT_INDEX = :au45_c # https://en.wikipedia.org/wiki/Facial_Action_Coding_System

  def run_openface_feature_extraction
    video_name = video_path.split("/").last.split(".").first
    out_dir = "analysis_out/#{video_name}"
    cmd = "#{FEATURE_EXTRACTION_PATH} -f #{video_path} -aus -out_dir #{out_dir}"

    Open3.popen3(cmd) do |_stdin, stdout, _stderr, _thread|
      while (line = stdout.gets)
        puts line
      end
    end

    log("FeatureExtraction analysis file written to #{out_dir}")

    "#{out_dir}/#{video_name}.csv"
  end

  def compute_blinks(feature_extraction_csv)
    log("Computing blinks from #{feature_extraction_csv}")

    blink_action_units = CSV.foreach(feature_extraction_csv, headers: true, header_converters: :symbol).map do |row|
      row[BLINK_ACTION_UNIT_INDEX].strip.to_f
    end

    blinks = 0
    currently_blinking = false

    blink_action_units.each do |au|
      if currently_blinking && au != 1.0
        currently_blinking = false
      elsif !currently_blinking && au == 1.0
        currently_blinking = true
        blinks += 1
      end
    end

    log("Number of blinks: #{blinks}")

    blinks
  end

  def log(str)
    puts "[BLINK DETECTION] #{str}"
  end
end
