# Gmail以外の通知手段は2019/8/18時点では考えていないのでGmailの処理を直接書いているが他の通知手段にする場合は各アダプタークラスを作成する
# 詳細は以下のドキュメントを参照
 # https://github.com/suzuki-mar/sst_api/wiki/%E9%80%9A%E7%9F%A5%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6
 
class ReminderNotifyer
  def initialize
    @to = ENV['GMAIL_ADDRESS']
    @password = ENV['GMAIL_PASSWORD']
  end

  def connectable?
    gmail = Gmail.connect!(@to, @password)
    gmail.logout
    true
  rescue Gmail::Client::AuthorizationError => e
    Rails.logger.error e.message
    false
  end

  def send(subject, body)
    Gmail.connect!(@to, @password) do |gmail|
      email = create_send_target_mail(gmail, subject, body)
      gmail.deliver!(email)
      return true
    end
  rescue Gmail::Client::DeliveryError => e
    Rails.logger.error e.message
    false
  end

  private

  # モック用の差し込みやすくするため
  def create_send_target_mail(gmail_client, subject, body)
    # ローカル変数に代入しないとgmail.composeで値を設定できない
    mail_address = @to

    gmail_client.compose do
      to mail_address
      subject subject
      body body
    end
  end
end
