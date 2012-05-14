require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get recover" do
    get :recover
    assert_response :success
  end

end
