class Frame < ApplicationRecord
  belongs_to :video

  validates_presence_of :frame, :face_id, :timestamp, :confidence, :success, :au45_c, :au45_r
end
