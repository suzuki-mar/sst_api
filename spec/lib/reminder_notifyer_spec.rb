# frozen_string_literal: true

require 'rails_helper'

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
