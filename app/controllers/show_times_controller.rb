class ShowTimesController < ApplicationController
  include Pagy::Backend

  # GET /show_times
  def index
    @q = ShowTime.ransack(params[:q])
    @pagy, @show_times = pagy(@q.result, limit: params[:per_page] || 5)
    # binding.pry 
    render json: {
      count_in_response: @show_times.size,
      show_times: @show_times,
      pagination: {
        count: @pagy.count,
        page: @pagy.page,
        per_page: @pagy.vars[:items],
        pages: @pagy.pages
      }
    }
  end
  
  

  # GET /show_times/:id
  def show
    show_time = ShowTime.find(params[:id])
    render json: show_time.as_json(only: [:id, :movie_id, :screen_id, :start_time, :end_time, :created_at])
  end
end
