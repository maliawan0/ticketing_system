require "test_helper"

class ShowTimesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get show_times_url
    assert_response :success
  end

  test "should get show" do
    show_time = show_times(:one)
    get show_time_url(show_time)
    assert_response :success
  end
end
