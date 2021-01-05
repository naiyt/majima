class VideosController < ApplicationController
  before_action :set_video, only: %i[show edit update destroy]

  # GET /videos
  def index
    @videos = Video.all
  end

  # GET /videos/1
  def show; end

  # GET /videos/new
  def new
    @video = Video.new
  end

  # GET /videos/1/edit
  def edit; end

  # POST /videos
  def create
    @video = Video.new(video_params)
    @video.status = Video::PROCESSING

    if @video.save
      @video.start_blink_detection_job
      render json: { success: true, id: @video.id }
    else
      render json: { errors: @video.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /videos/1
  def update
    if @video.update(video_params)
      redirect_to @video, notice: "Video was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /videos/1
  def destroy
    @video.destroy
    redirect_to videos_url, notice: "Video was successfully destroyed."
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_video
    @video = Video.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def video_params
    params.permit(:video_file, :started_recording_at)
  end
end
