module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :ip, :websocket_key

    def connect
      self.ip = request.remote_ip

      # Each websocket connection generates a unique key.
      # This will allow us to differentiate between browser tabs
      self.websocket_key = request.env['HTTP_SEC_WEBSOCKET_KEY']
    end

    def encode(cable_message)
      return if cable_message.has_key?(:type)

      id_hash = JSON.parse(cable_message[:identifier]) rescue {}

      if id_hash['channel'] == HermesChannel.name
        data = cable_message[:message]
        data = data[0] == '{' ? JSON.parse(data) : data

        # The hermes client expects this format
        return {
          'subscription' => id_hash['topic'],
          'topic'        => id_hash['topic'],
          'data'         => data,
        }.to_json
      end

      super
    end

    def decode(websocket_message)
      if websocket_message[0] == '{'
        super
      else
        # The hermes client just sends the topic name
        {
          'command'    => 'subscribe',
          'identifier' => {
            'channel'  => HermesChannel.name,
            'topic'    => websocket_message,
          }.to_json
        }
      end
    end

    # Disable pings.
    #
    # For now we're going to rely on the WebSocket/TCP to notify us
    # When the WebSocket disconnects (eg via tab closure)
    def beat
    end

  end
end
