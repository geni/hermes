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

  test 'dashboard' do
    get :dashboard

    result = JSON.parse(response.body)
    assert_equal 0, result['total_subscribers'], 'total_subscribers should be 0'
    assert_equal 0, result['total_subscriptions'], 'total_subscriptions should be 0'
  end

end
