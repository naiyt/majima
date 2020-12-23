require "csv"
require "./logger.cr"

class BlinkDetector
  private OUTDIR_PATH = File.join(ENV["MAJIMA_PATH"], "/data/analysis_out")

  def self.detect(video_path : String) : String
    video_name = video_path.split("/").last.split(".").first
    out_dir = [OUTDIR_PATH, video_name].join("/")

    switches = [
      "-f #{video_path}",
      "-out_dir #{out_dir}",
      "-aus",
    ]

    log("Running cmd #{ENV["OPENFACE_EXECUTABLE_PATH"]} #{switches.join(' ')}")

    output = `#{ENV["OPENFACE_EXECUTABLE_PATH"]} #{switches.join(' ')}`
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
end
