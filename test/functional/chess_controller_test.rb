require 'test_helper'

class ChessControllerTest < ActionController::TestCase
  test "should get chess" do
    get :chess
    assert_response :success
  end

end
