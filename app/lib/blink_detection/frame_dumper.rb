require "csv"

module BlinkDetection
  module FrameDumper
    def self.dump(video, feature_extraction_analysis_path)
      csv = Dir[File.join(feature_extraction_analysis_path, "*.csv")].first
      frames =
        CSV
          .foreach(csv, headers: true, header_converters: :symbol)
          .map do |row|
            {
              video_id: video.id,
              frame: row[:frame].strip,
              face_id: row[:face_id].strip,
              timestamp: row[:timestamp].strip,
              confidence: row[:confidence].strip,
              success: ActiveModel::Type::Boolean.new.cast(row[:success].strip),
              au45_r: row[:au45_r].strip,
              au45_c: row[:au45_c].strip,
            }
          end

      Frame.upsert_all(frames, unique_by: :index_frames_on_frame_and_video_id)
    end
  end
end
