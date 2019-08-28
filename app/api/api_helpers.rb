# frozen_string_literal: true

module ApiHelpers
  # 1人のユーザーしか使わない想定
  def current_user
    User.last
  end

  def create_error_message_from_model(model)
    error_message = model.errors.messages.reduce('') do |message, (name, msgs)|
      message += "#{name}:"
      msgs.each do |msg|
        message += "#{msg},"
      end
      message.slice!(-1)
      message += "\n"
    end
    error_message.slice!(-1)
    error_message
  end
end
