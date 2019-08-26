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
            {'id' =>  "", 'name' => "name1",  'order_number' => 1},
          ],
  
          'normal' => [
            {'id' =>  "", 'name' =>  "name1",  'order_number' =>  2},
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
              {'id' =>  "", 'name' => "name1",  'order_number' => 1},
            ],
    
            'normal' => [
              {'id' =>  "", 'name' =>  "name1",  'order_number' =>  2},
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
              {'id' =>  "", 'name' => "name1",  'order_number' => 1},
            ],
    
            'normal' => [
              {'id' =>  "", 'name' =>  "name1",  'order_number' =>  2},
            ]
          }
        }

        it 'バリデーションエラーメッセージを取得できること' do
          subject 
          expect(form.errors.messages[:kind_name]).to eq(['足りない項目名があります:bad'])
        end

      end

      context 'パラメーターに必要ではない項目がある場合' do 
        let(:params){
          {
            'good' =>  [{'id' =>  "",  'name' => "name1"},],
            'normal' => [{'id' =>  "",  'order_number' =>  2},],
            'bad' => [{'id' =>  "",  'name' => "name1", 'order_number' =>  2, 'unknow_param': 'hoge'}]
          }
        }
  
        it 'バリデーションメッセージを取得できること' do
          subject 
          expect(form.errors.messages[:params]).to eq(['不正なパラメーターが渡された項目があります:good,normal,bad'])
        end
  
      end

     pending  '存在しないIDをパラメーターにした場合'

    end

  end

  describe 'save!' do
    subject {form.save!}

    context 'パラメーターが正しい場合' do

      context '新規作成の場合' do
        let(:params){
          {
            'good' =>  [
              {'id' =>  "",  'name' => "name1",  'order_number' => 1},
            ],
    
            'normal' => [
              {'id' =>  "",  'name' =>  "name1",  'order_number' =>  4},
              {'id' =>  "",  'name' =>  "name2",  'order_number' =>  2}
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
    
          it 'order_numberを正しく設定できていること' do
            subject
            order_numbers = SelfCareClassification.where(kind: :normal).pluck(:order_number)
            expect(order_numbers).to eq([1, 2])
          end
      end

      context 'すでにデータが有る場合' do
        let(:params){
          {
            'good' =>  [
              {'id' =>  "",  'name' => "name1",  'order_number' => "1"},
              {'id' =>  "", 'name' => "name2",  'order_number' => "5"},
              {'id' => good_classification.id, 'name' => "name2",  'order_number' => "4"},
            ],
            'normal' => [{'id' => normal_classification.id, 'name' => "name1",  'order_number' => "1"}],
            'bad' => [],
          }
        }

        let(:good_classification){create(:self_care_classification, user: user, order_number:5, kind: :good)}
        let(:normal_classification){create(:self_care_classification, user: user, order_number:5, kind: :normal)}

          it 'グループごとに作成できていること' do
            subject
            # TODO scopeを設定する
            expect(SelfCareClassification.where(kind: :good).count).to eq(3)
          end

      end
      
    end

    context 'パラメーターがエラーの場合' do

      context 'パラメーターが足りない場合' do
        let(:params){
          {
            'good' =>  [
              {'id' =>  "",  'name' => "name1",  'order_number' => 1},
            ],
    
            'normal' => [
              {'id' =>  "",  'name' =>  "name1",  'order_number' =>  2},
            ]
          }
        }
    
        it '例外が発生すること' do
          expect { subject }.to raise_error(SelfCareClassificationsForm::InvalidError)
        end
      end

      pending '同じ項目名で同じorder_numberが存在する場合''' 
      pending '保存に1つでも失敗した場合に全件保存されないこと'

    end
  
  end
end
