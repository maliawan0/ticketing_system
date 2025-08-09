require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get movies_url
    assert_response :success
  end

  test "should get show" do
    movie = movies(:one)
    get movie_url(movie)
    assert_response :success
  end

  test "should get create" do
    post movies_url, params: { movie: { title: "T", category: "C", genre: "G", language: "EN", duration: 90, rating: 8 } }
    assert_response :created
  end

  test "should get update" do
    movie = movies(:one)
    patch movie_url(movie), params: { movie: { title: "Updated" } }
    assert_response :success
  end

  test "should get destroy" do
    movie = movies(:one)
    delete movie_url(movie)
    assert_response :no_content
  end

  test "should get restore" do
    movie = movies(:one)
    delete movie_url(movie)
    patch restore_movie_url(movie)
    assert_response :success
  end
end
