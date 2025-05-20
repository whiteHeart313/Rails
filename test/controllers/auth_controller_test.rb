require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get singIn" do
    get auth_singIn_url
    assert_response :success
  end

  test "should get signUp" do
    get auth_signUp_url
    assert_response :success
  end
end
