# frozen_string_literal: true

require 'rails_helper'

describe 'self_care_classificaiton', type: :request do
  describe 'GET /v1/self_cares/recent' do
    let(:log_dates) do
      [
        Time.zone.now - 6.days,
        Time.zone.now,
        Time.zone.now - 7.days
      ]
    end

    before do
      user = create(:user)
      classification = create(:self_care_classification, user: user)

      log_dates.each_with_index do |date_time, i|
        create(:self_care, log_date: date_time, user: user,
                           self_care_classification: classification, reason: "reason#{i}")
      end

      another_user = create(:user)
      another_user_classification = create(:self_care_classification, user: another_user)
      create(:self_care, log_date: Time.zone.yesterday, user: another_user,
                         self_care_classification: another_user_classification)
    end

    it 'ステータスコードを取得できること' do
      get '/v1/self_cares/recent'

      expect(response.status).to eq 200
    end

    it 'セルフケアを取得できること' do
      get '/v1/self_cares/recent'

      parsed_api_respone = JSON.parse(response.body)
      expect(parsed_api_respone.pluck('reason')).to eq(%w[reason1 reason0])
    end
  end
end
