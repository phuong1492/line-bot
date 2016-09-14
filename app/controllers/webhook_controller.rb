require "line_bot"
class WebhookController < ApplicationController
  protect_from_forgery with: :null_session

  def callback
    unless is_validate_signature
      render nothing: true, status: 470
    end
    result = params[:result][0]
    content = result["content"]

    LineBot.new.send [content["from"]], 1, content["text"] # 1: Text
    render nothing: true, status: :ok
  end

  private
  def is_validate_signature
    signature = request.headers["X-LINE-ChannelSignature"]
    channel_secret = "5dfd53b08499b3d8d6fdc9bb051f0ee6"
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest OpenSSL::Digest::SHA256.new, channel_secret, http_request_body
    signature_answer = Base64.strict_encode64 hash
    signature == signature_answer
  end
end
