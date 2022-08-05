require "test_helper"

class HermesControllerTest < ActionDispatch::IntegrationTest

  test "publish requires PUT" do
    put "/"
    assert_response 200
  end

  test "GET publish fails" do
    get "/"
    assert_response 405
  end
end
