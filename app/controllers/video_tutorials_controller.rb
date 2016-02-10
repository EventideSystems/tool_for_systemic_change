class VideoTutorialsController < AuthenticatedController
  before_action :set_video_tutorial, only: [:show]

  resource_description do
    formats ['json']
  end

  api :GET, '/video_tutorials'
  def index
    query = VideoTutorial.order(updated_at: :desc)

    @video_tutorials = finder_for_pagination(query).all

    render json: @video_tutorials
  end


  api :GET, '/video_tutorials/:id'
  param :id, :number, required: true
  def show
    render json: @video_tutorial
  end

  api :GET, '/video_tutorials/dashboard'
  def dashboard
    @video_tutorials = VideoTutorial.
      where(promote_to_dashboard: true).
      order(:position)

    render json: @video_tutorials
  end



  private

  def set_video_tutorial
    @video_tutorial = VideoTutorial.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise User::NotAuthorized
  end

end
