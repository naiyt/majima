class Frame < ApplicationRecord
  belongs_to :video

  validates_presence_of :frame, :face_id, :timestamp, :confidence, :success, :AU45_c, :AU45_r
end
