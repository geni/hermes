require 'test_helper'

class RoutesTest < ActionDispatch::IntegrationTest

  test 'path gets mapped to topic' do
    assert_generates '/foo', :controller => 'hermes', :action => 'publish', :topic => 'foo'
  end

end # class RoutesTest