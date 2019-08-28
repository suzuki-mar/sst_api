# frozen_string_literal: true

class ResultResponse
  def initialize(message)
    @message = message
  end

  def to_respnose
    {
      message: @message
    }.to_json
  end
end
