# frozen_string_literal: true

require 'rails_helper'

describe SelfCareClassificationsForm, type: :model do
  let(:user){create(:user)}
  let(:form){SelfCareClassificationsForm.new(user, params)}

  describe 'validate' do
    subject {form.validate}

    context 'パラメーターが正しい場合' do 
      let(:params){
        {
          'good' =>  [
            {'name' => "name1",  'order_number' => 1},
          ],
  
          'normal' => [
            {'name' =>  "name1",  'order_number' =>  2},
          ],
  
          'bad' => [
          ]
        }
      }

      it 'バリデーションエラーがないこと' do
        is_expected.to be_truthy
      end

    end

    context 'パラメーターが間違っている場合' do
      context 'kind_nameにエラーがある場合' do
        let(:params){
          {
            'good' =>  [
              {'name' => "name1",  'order_number' => 1},
            ],
    
            'normal' => [
              {'name' =>  "name1",  'order_number' =>  2},
            ],
    
            'bad' => [
            ],
            'error' => [
            ]
          }
        }

        it 'バリデーションエラーメッセージを取得できること' do
          subject 
          expect(form.errors.messages[:kind_name]).to eq(['不正な項目名が渡されました:error'])
        end

      end

      context 'kind_nameのkeyが足りていない場合' do
        let(:params){
          {
            'good' =>  [
              {'name' => "name1",  'order_number' => 1},
            ],
    
            'normal' => [
              {'name' =>  "name1",  'order_number' =>  2},
            ]
          }
        }

        it 'バリデーションエラーメッセージを取得できること' do
          subject 
          expect(form.errors.messages[:kind_name]).to eq(['足りない項目名があります:bad'])
        end

      end

      context '不正なパラメーターがある場合' do 
        let(:params){
          {
            'good' =>  [{'name' => "name1"},],
            'normal' => [{ 'order_number' =>  2},],
            'bad' => [{'name' => "name1", 'order_number' =>  2, 'unknow_param': 'hoge'}]
          }
        }
  
        it 'バリデーションメッセージを取得できること' do
          subject 
          expect(form.errors.messages[:params]).to eq(['不正なパラメーターが渡された項目があります:good,normal,bad'])
        end
  
      end

    end

  end

  describe 'save!' do
    subject {form.save!}

    context 'パラメーターが正しい場合' do
      let(:params){
      {
        'good' =>  [
          {'name' => "name1",  'order_number' => 1},
        ],

        'normal' => [
          {'name' =>  "name1",  'order_number' =>  2},
        ],

        'bad' => [
        ],
      }
    }

      it 'パラメーター数作成できること' do
        subject
        expect(SelfCareClassification.where(name: "name1").count).to eq(2)
      end

      it 'グループごとに作成できていること' do
        subject
        # TODO scopeを設定する
        expect(SelfCareClassification.where(kind: :good).count).to eq(1)
      end

    end

    context 'パラメーターがエラーの場合' do
      let(:params){
        {
          'good' =>  [
            {'name' => "name1",  'order_number' => 1},
          ],
  
          'normal' => [
            {'name' =>  "name1",  'order_number' =>  2},
          ]
        }
      }
  
      it '例外が発生すること' do
        expect { subject }.to raise_error(SelfCareClassificationsForm::InvalidError)
      end
  
    end
  
  end
end
