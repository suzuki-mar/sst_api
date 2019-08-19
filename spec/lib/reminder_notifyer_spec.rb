# frozen_string_literal: true

require 'rails_helper'

# Gmail以外の通知手段は2019/8/18時点では考えていないのでGmailの処理を直接書いているが他の通知手段にする場合は各アダプタークラスを作成する
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

describe ReminderNotifyer, type: :lib, use_external_network: 'true' do
  let(:notifyer) { described_class.new }

  describe 'connectable?' do
    it '接続情報があっている場合はtrueがかえること' do
      expect(notifyer).to be_connectable
    end

    it '接続情報があっていない場合はtrueがかえること' do
      dummy_notifier = described_class.new
      dummy_notifier.instance_variable_set(:@to, 'error')
      dummy_notifier.instance_variable_set(:@password, 'error')

      expect(dummy_notifier).not_to be_connectable
    end
  end

  describe 'send' do
    it '送信できた場合はtrueが帰ること' do
      expect(notifyer.send('疎通確認', '疎通確認')).to be_truthy
    end

    it '送信途中で何らかのエラーが発生した場合はfalseが帰ること' do
      dummy_mail = instance_double(Mail::Message, 'ダミーメッセージ')
      allow(dummy_mail).to receive(:deliver!).and_raise(StandardError)
      allow(notifyer).to receive(:create_send_target_mail).and_return(dummy_mail)
      expect(notifyer.send('疎通確認', '疎通確認')).to be_falsey
    end
  end
end
