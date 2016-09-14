# require "faraday"
# require "faraday_middleware"
require "json"
require "pp"

class LineBot
  module ContentType
    TEXT = 1
    IMAGE = 2
    VIDEO = 3
    AUDIO = 4
    LOCATION = 7
    STICKER = 8
    CONTACT = 10
  end
  module ToType
    USER = 1
  end

  END_POINT = "https://trialbot-api.line.me" # Fixed value
  TO_CHANNEL = 1480676957 # Fixed value
  EVENT_TYPE = "138311609000106303" # Fixed value

  def initialize
    @channel_id = "1480676957"
    @channel_secret = "5dfd53b08499b3d8d6fdc9bb051f0ee6"
    @channel_mid = "u3bd10d427ec7172237db7f71004a8021"
  end

  def post path, data
    client = Faraday.new url: END_POINT do |conn|
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.adapter Faraday.default_adapter
    end
    res = client.post do |request|
      request.url path
      request.headers = {
        "Content-Type" => "application/json; charset=UTF-8",
        "X-Line-ChannelID" => @channel_id,
        "X-Line-ChannelSecret" => @channel_secret,
        "X-Line-Trusted-User-With-ACL" => @channel_mid,
      }
      request.body = data
    end
    res
  end

  def send line_ids, contentType, message, options = nil
    message_type_name = case contentType
      when ContentType::TEXT
        "text"
      when ContentType::IMAGE, ContentType::VIDEO
        ""
      when ContentType::AUDIO, ContentType::STICKER
        "contentMetadata"
      else
        "text"
      end

    content = {
      contentType: contentType,
      toType: ToType::USER,
      "#{message_type_name}": message
    }
    if options
      options.each do |key, value|
        content[key] = value
      end
    end
    post "/v1/events", {
      to: line_ids,
      content: content,
      toChannel: TO_CHANNEL,
      eventType: EVENT_TYPE
    }
  end
end
