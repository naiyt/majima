require "open3"

class BlinkDetector
  def initialize(video_path)
    @video_path = video_path
  end

  def detect
    log("Running OpenFace FeatureExtraction on #{video_path}")
    run_openface_feature_extraction
  end

  private

  attr_reader :video_path

  FEATURE_EXTRACTION_PATH = "/home/openface-build/build/bin/FeatureExtraction".freeze

  def run_openface_feature_extraction
    video_name = video_path.split("/").last.split(".").first
    cmd = "#{FEATURE_EXTRACTION_PATH} -f #{video_path} -aus -out_dir analysis_out/#{video_name}"

    Open3.popen3(cmd) do |_stdin, stdout, _stderr, _thread|
      while (line = stdout.gets)
        puts line
      end
    end

    log("Analysis file written to analysis_out/#{video_name}")
  end

  def log(str)
    puts "[BLINK DETECTION] #{str}"
  end
end
