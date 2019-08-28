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

  describe 'POST /v1/self_care_classifications/group' do
    let!(:user){create(:user)}
    
    subject(:post_group) do
      post '/v1/self_care_classifications/group', params: { input_params: params } 
    end
    
    context '新規作成のみ' do
      let(:params) do
        [{
          'good' => [
            { 'id' =>  '',  'name' => 'name1', 'order_number' => 1 }
          ],

          'normal' => [
            { 'id' =>  '',  'name' =>  'name1',  'order_number' =>  '4' },
            { 'id' =>  '',  'name' =>  'name2',  'order_number' =>  '2' }
          ],

          'bad' => []
        }]
      end

      it 'レスポンスを取得できること' do
        post_group
        
        expect(response.status).to eq 204
        parsed_api_respone = JSON.parse(response.body)
        expect(parsed_api_respone).to eq({"message"=>"success"})
      end

      it '作成できていること' do
        post_group
        
        expect(SelfCareClassification.kind_by(:normal).count).to eq(2)
      end
    end

    context 'バリデーションエラーの場合' do
      let(:params) do
        [{
          'good' => [
            { 'id' =>  '',  'name' => 'name1', 'order_number' => 1 }
          ],

          'normal' => [
            { 'id' =>  '',  'name' =>  'name1',  'order_number' =>  '2' },
            { 'id' =>  '',  'name' =>  'name1',  'order_number' =>  '2' }
          ]
        }]
      end

      it 'エラーレスポンスを取得できること' do
        post_group
        
        expect(response.status).to eq 400
        parsed_api_respone = JSON.parse(response.body)
        expected_message = "kind_name:足りない項目名があります:bad\n" +
        "params:同じ順番が設定されています:normal,同じ名前が設定されています:normal"
        expect(parsed_api_respone['error']).to eq(expected_message)
      end

      it '一部だけ保存に成功していないこと' do
        post_group
        
        expect(SelfCareClassification.count).to eq(0)
      end
    end

    context '更新する場合' do
      let(:params) do
        [{
          'good' => [
            { 'id' =>  '',  'name' => 'name1', 'order_number' => 1 },
            { 'id' =>  classification.id,  'name' => 'name2', 'order_number' => 2 }
          ],

          'normal' => [
            { 'id' =>  '',  'name' =>  'name1',  'order_number' =>  '2' },
            { 'id' =>  '',  'name' =>  'name2',  'order_number' =>  '1' }
          ],
          'bad' => []
        }]
      end
      let(:classification){create(:self_care_classification, kind: :good, user: user)}

      it 'エラーレスポンスを取得できること' do
        post_group
       
        parsed_api_respone = JSON.parse(response.body)
        expect(response.status).to eq 204
        parsed_api_respone = JSON.parse(response.body)
        expect(parsed_api_respone).to eq({"message"=>"success"})
      end

      it '保存に成功していないこと' do
        post_group
        
        expect(SelfCareClassification.kind_by(:good).count).to eq(2)
      end
    end

  end
end
