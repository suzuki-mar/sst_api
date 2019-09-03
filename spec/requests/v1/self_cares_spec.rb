# frozen_string_literal: true

require 'rails_helper'

describe 'self_care_classification', type: :request do
  describe 'POST /v1/self_cares' do
    subject(:post_self_care) { post '/v1/self_cares', params: { input_params: [param] } }

    let(:user) { create(:user) }
    let(:classification) { create(:self_care_classification, user: user) }

    context 'パラメーターが正常の場合' do
      let(:param) do
        param = attributes_for(:self_care)
        param[:user_id] = user.id
        param[:self_care_classification_id] = classification.id

        param
      end

      it 'レスポンスが返ること' do
        post_self_care

        expect(response.status).to eq 204
      end

      it '作成できること' do
        expect { post_self_care }.to change(SelfCare, :count).from(0).to(1)
      end
    end

    context 'パラメーターが間違っている場合' do
      shared_examples 'パラメーターが間違っている場合の対応ができていること' do |expected_messge|
        it 'エラーになっていること' do
          post_self_care

          expect(response.status).to eq 400
        end

        it '保存ができていないこと' do
          post_self_care

          expect(SelfCare.count).to eq(0)
        end

        it 'エラーメッセージを取得できること' do
          post_self_care

          parsed_api_respone = JSON.parse(response.body)
          expect(parsed_api_respone['error']).to eq(expected_messge)
        end
      end

      context '不正なパラメーターの場合' do
        let(:param) do
          param = attributes_for(:self_care)
          param.delete(:reason)
          param[:user_id] = user.id
          param[:self_care_classification_id] = classification.id
          param
        end

        include_examples 'パラメーターが間違っている場合の対応ができていること', "reason:can't be blank"
      end

      context '存在しないclassificationIDを指定した場合' do
        let(:param) do
          param = attributes_for(:self_care)
          param[:user_id] = user.id
          param[:self_care_classification_id] = 999_999_999_999_999_999
          param
        end

        include_examples 'パラメーターが間違っている場合の対応ができていること', '存在しない分類に登録しようとしました'
      end

      context '別ユーザーの分類を登録しようとした場合' do
        let(:param) do
          param = attributes_for(:self_care)
          param[:user_id] = user.id
          another_classificaiton = create(:self_care_classification)
          param[:self_care_classification_id] = another_classificaiton.id
          param
        end

        error_msg = 'self_care_classification:user_idとself_care_classificationのuser_idが同一ではありません'
        include_context 'パラメーターが間違っている場合の対応ができていること', error_msg
      end
    end
  end

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
