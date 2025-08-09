class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :update, :destroy, :restore]

  # GET /movies
  # GET /movies
  # 
  
  def index
    q = Movie.ransack(params[:q])
    @movies = q.result.page(params[:page]).per(params[:per_page] || 10)
  
    # Ensure params[:q] is a hash or blank string for cache key
    query_param = params[:q].present? ? params[:q].to_param : 'all'
  
    cache_key = "movies/index/#{query_param}/page-#{params[:page] || 1}-per-#{params[:per_page] || 10}"
    # binding.pry
    movies_json = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
      # Rails.logger.info "Cache miss for #{cache_key}"  # Log cache misses
      # binding.pry
      @movies.as_json(only: [:id, :title, :category, :genre, :language, :duration, :rating, :created_at]).to_json
    end
  
    render json: {
      movies: JSON.parse(movies_json),
      pagination: {
        current_page: @movies.current_page,
        next_page: @movies.next_page,
        prev_page: @movies.prev_page,
        total_pages: @movies.total_pages,
        total_count: @movies.total_count
      }
    }
  end
  
  # GET /movies/:id
  def show
    render json: @movie
  end

  # POST /movies
  def create
    @movie = Movie.new(movie_params)
    if @movie.save
      render json: @movie, status: :created
    else
      render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /movies/:id
  def update
    if @movie.update(movie_params)
      render json: @movie
    else
      render json: { errors: @movie.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /movies/:id (Soft delete)
  def destroy
    @movie.soft_delete
    head :no_content
  end

  # PATCH /movies/:id/restore
  def restore
    @movie.restore
    render json: @movie
  end

  private

  def set_movie
    @movie = Movie.with_deleted.find(params[:id])
  end

  def movie_params
    params.require(:movie).permit(:title, :category, :genre, :language, :duration, :rating)
  end
end
