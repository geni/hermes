class HermesChannel < ApplicationCable::Channel
  def subscribed
    stream_from params[:topic]
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
