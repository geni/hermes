require "test_helper"

class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase

  def setup
    connect '/websocket', :headers => {"REMOTE_ADDR" => '127.0.0.42'}

    # TestCase.connect includes the TestCase::TestConnection module
    # which overrides the init method, but doesn't set the coder.
    connection.instance_variable_set(:@coder, ActiveSupport::JSON)
  end

  test 'connect' do
    assert_equal '127.0.0.42', connection.ip
  end

  test 'connect parses X-FORWARDED-FOR header' do
    connect '/websocket', :headers => {"HTTP_X_FORWARDED_FOR" => '1.1.1.1,2.2.2.2'}
    assert_equal '1.1.1.1', connection.ip
  end

  test 'encode returns blank for typed message' do
    assert_nil connection.encode({:type => 'welcome'})
  end

  test 'encode returns hermes compatible message' do
    cable_message = {
      :identifier => {
        :channel => HermesChannel.name,
        :topic   => 'topic',
      }.to_json,
      :message    => 'message',
    }

    expected = {
      :subscription => 'topic',
      :topic        => 'topic',
      :data         => 'message',
    }.to_json
    assert_equal expected, connection.encode(cable_message)
  end

  test 'encode returns cable compatible message' do
    cable_message = {
      :identifier => {
        :channel => 'DummyChannel',
        :topic   => 'topic',
      }.to_json,
      :message    => 'message',
    }

    expected = cable_message.to_json
    assert_equal expected, connection.encode(cable_message)
  end

  test 'decode handles hermes compatible message' do
    topic = "hermes:test"
    expected = {
      "command"    => "subscribe",
      "identifier" => {
        "channel"  => "HermesChannel",
        "topic"    => topic,
      }.to_json
    }
    assert_equal expected, connection.decode(topic)
  end

  test 'decode handles cable compatible message' do
    topic = "hermes:test"
    expected = {
      "command"    => "subscribe",
      "identifier" => {
        "channel"  => "HermesChannel",
        "topic"    => topic,
      }.to_json
    }
    assert_equal expected, connection.decode(expected.to_json)
  end

end # class ApplicationCable::ConnectionTest
