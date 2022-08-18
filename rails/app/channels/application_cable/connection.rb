module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :ip, :websocket_key

    def connect
      self.ip = remote_ip

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

  private

    def remote_ip
      @remote_ip ||= if request.env['HTTP_X_FORWARDED_FOR']
        # some proxy is prepending non-routable IP addresses to the forwarded_for header
        # we want to skip those and return the first routable IP
        candidates = request.env['HTTP_X_FORWARDED_FOR'].split(',').apply(:strip)
        if candidates.size == 1
          candidates.first
        else
          candidates.detect {|ip| ip =~ /^:*\d+\.\d+\.\d+\.\d+$/ && IPAddr.routable?(ip)}
        end
      else
        request.remote_ip
      end.sub(/^::/, '') # Not ready for IPv6
    end

  end
end
