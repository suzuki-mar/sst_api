# frozen_string_literal: true

require 'rails_helper'

describe 'self_care_classificaiton', type: :request do
  describe 'GET /v1/self_care_classifications' do
    it 'セルフケア分類を取得できること' do
      create(:self_care_classification)

      get '/v1/self_care_classifications'

      expect(response.status).to eq 200

      parsed_api_respone = JSON.parse(response.body)
      expect(parsed_api_respone[0].keys).to eq(%w[id name order_number kind])
    end
  end

  # describe 'GET /v1/self_care_classifications' do
  #   it 'セルフケア分類を取得できること' do
  #     create(:self_care_classification)

  #     post '/v1/self_care_classifications'

  #     expect(response.status).to eq 200

  #     parsed_api_respone = JSON.parse(response.body)
  #     expect(parsed_api_respone[0].keys).to eq(%w[id name order_number kind])
  #   end
  # end


end
