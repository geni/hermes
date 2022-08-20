class Dashboard

  def total_subscribers
    subscriber_map.keys.count { |topic| topic.starts_with?('action_cable/') }.to_i
  end

  def total_subscriptions
    subscriber_map.keys.count { |topic| !topic.starts_with?('action_cable/') }.to_i
  end

  def to_json
    {
      :total_subscribers   => total_subscribers,
      :total_subscriptions => total_subscriptions,
    }
  end

  # Brittle - dependendent on ActionCable internals
  def subscriber_map
    return @subscriber_map if defined?(@subscriber_map)

    subscriber_map = ActionCable.server.pubsub.send(:subscriber_map)
    mutex          = subscriber_map.instance_variable_get(:@sync)
    mutex.synchronize do
      return @subscriber_map = subscriber_map.instance_variable_get(:@subscribers).dup
    end
  end 

end # class Dashboard