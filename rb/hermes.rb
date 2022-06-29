require 'rubygems'
require 'faraday'
require 'faraday_middleware'

class Hermes
  class NetworkException < StandardError
    attr_reader :cause
    def initialize(cause)
      super("#{cause.class.name}: #{cause.message}") if @cause = cause
    end
  end

  attr_reader :http

  def initialize(url='http://localhost:2960', opts=nil)
    opts ||= {}

    @http = Faraday.new(:url => url) do |faraday|
      # sets both open and read timeouts
      faraday.options[:timeout] = opts[:timeout] || 10 # seconds
      faraday.request :json
      faraday.adapter Hermes.adapter
    end

  rescue Exception => e
    raise NetworkException.new(e)
  end

  def escape_topic(topic)
    # Faraday does not like colons in your url.
    URI.escape(topic).gsub(':', '%3A')
  end

  def publish(topic, data = {}, &block)
    data = block.call if block
    topic = escape_topic(topic)
    begin
      http.put(topic, data)
    rescue Exception => e
      raise NetworkException.new(e)
    end
  end

  def self.adapter(adapter = nil)
    @adapter = adapter if adapter
    @adapter ||= :net_http
  end
end
