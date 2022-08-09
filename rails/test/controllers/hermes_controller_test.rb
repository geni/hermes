require 'test_helper'

class HermesControllerTest < ActionController::TestCase

  test 'index returns OK' do
    get :index
    assert_response 200
    assert_equal 'OK', response.body
  end

  test 'publish with PUT' do
    put :publish, :params => {:topic => 'foo'}, :body => '{}'
    assert_response 200
  end

end
