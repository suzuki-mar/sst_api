# frozen_string_literal: true

require 'rails_helper'

describe SelfCareClassificationsForm, type: :form do
  let(:user) { create(:user) }
  let(:form) { described_class.new(user, params) }

  describe 'validate' do
    subject(:validate) { form.validate }

    context 'パラメーターが正しい場合' do
      let(:params) do
        {
          'good' => [
            { 'id' =>  '', 'name' => 'name1', 'order_number' => 1 }
          ],
          'normal' => [
            { 'id' =>  '', 'name' => 'name1', 'order_number' => 2 }
          ],
          'bad' => []
        }
      end

      it 'バリデーションエラーがないこと' do
        is_expected.to be_truthy
      end
    end

    context 'パラメーターが間違っている場合' do
      context 'kind_nameにエラーがある場合' do
        let(:params) do
          {
            'good' => [
              { 'id' =>  '', 'name' => 'name1', 'order_number' => 1 }
            ],

            'normal' => [
              { 'id' =>  '', 'name' => 'name1', 'order_number' => 2 }
            ],

            'bad' => [],
            'error' => []
          }
        end

        it 'バリデーションエラーメッセージを取得できること' do
          validate
          expect(form.errors.messages[:kind_name]).to eq(['不正な項目名が渡されました:error'])
        end
      end

      context 'kind_nameのkeyが足りていない場合' do
        let(:params) do
          {
            'good' => [
              { 'id' =>  '', 'name' => 'name1', 'order_number' => 1 }
            ],

            'normal' => [
              { 'id' =>  '', 'name' => 'name1', 'order_number' => 2 }
            ]
          }
        end

        it 'バリデーションエラーメッセージを取得できること' do
          validate
          expect(form.errors.messages[:kind_name]).to eq(['足りない項目名があります:bad'])
        end
      end

      context '同じ項目名で同じorder_numberが存在する場合' do
        let(:params) do
          {
            'good' => [
              { 'id' =>  '', 'name' => 'name1', 'order_number' => 1 },
              { 'id' =>  '', 'name' => 'name1', 'order_number' => 1 }
            ],

            'normal' => [
              { 'id' =>  '', 'name' => 'name1', 'order_number' => 2 }
            ],

            'bad' => []
          }
        end

        it 'バリデーションエラーメッセージを取得できること' do
          validate
          expect(form.errors.messages[:params]).to eq(['同じ順番が設定されています:good'])
        end
      end

      context 'パラメーターに必要ではない項目がある場合' do
        let(:params) do
          {
            'good' => [{ 'id' => '', 'name' => 'name1', 'order_number' => 1 }],
            'normal' => [{ 'id' => '',  'name' => 'name1', 'order_number' => 2 }],
            'bad' => [
              { 'id' => '', 'name' => 'name1', 'order_number' => 2, 'unknow_param': 'hoge' }
            ]
          }
        end

        it 'バリデーションメッセージを取得できること' do
          validate
          expect(form.errors.messages[:params]).to eq(['不正なパラメーターが渡された項目があります:bad'])
        end
      end

      context '存在しないIDをパラメーターにした場合' do
        let(:params) do
          {
            'good' => [
              { 'id' => '99999999999999999999', 'name' => 'name1', 'order_number' => 2 }
            ],
            'normal' => [
              { 'id' => other_user_classification.id, 'name' => 'name1', 'order_number' => 2 }
            ],
            'bad' => []
          }
        end
        let(:other_user_classification) { create(:self_care_classification) }

        it 'バリデーションメッセージを取得できること' do
          validate
          expect(form.errors.messages[:params]).to eq(['不正なIDが渡された項目があります:good,normal'])
        end
      end

      context 'SelfCareClassificationのバリデーションに失敗するものがある場合' do
        let(:params) do
          {
            'good' => [
              { 'id' => '', 'name' => '', 'order_number' => 2 }
            ],
            'normal' => [],
            'bad' => []
          }
        end

        it 'バリデーションメッセージを取得できること' do
          validate
          expect(form.errors.messages[:params]).to eq(['バリデーションエラーが発生しました:good'])
        end
      end

    end
  end

  describe 'save!' do
    subject(:save!) { form.save! }

    context 'パラメーターが正しい場合' do
      context '新規作成の場合' do
        let(:params) do
          {
            'good' => [
              { 'id' =>  '',  'name' => 'name1', 'order_number' => 1 }
            ],

            'normal' => [
              { 'id' =>  '',  'name' =>  'name1',  'order_number' =>  '4' },
              { 'id' =>  '',  'name' =>  'name2',  'order_number' =>  '2' }
            ],

            'bad' => []
          }
        end

        it 'パラメーター数作成できること' do
          save!
          expect(SelfCareClassification.where(name: 'name1').count).to eq(2)
        end

        it 'グループごとに作成できていること' do
          save!
          # TODO: scopeを設定する
          expect(SelfCareClassification.where(kind: :good).count).to eq(1)
        end

        it 'order_numberを正しく設定できていること' do
          save!
          order_numbers = SelfCareClassification.where(kind: :normal).pluck(:order_number)
          expect(order_numbers).to eq([1, 2])
        end
      end

      context 'すでにデータが有る場合' do
        let(:params) do
          {
            'good' => [
              { 'id' =>  '',  'name' => 'name1', 'order_number' => '1' },
              { 'id' =>  '', 'name' => 'name2', 'order_number' => '5' },
              { 'id' => good_classification.id, 'name' => 'name2',  'order_number' => '4' }
            ],
            'normal' => [
              { 'id' => normal_classification.id, 'name' => 'name1', 'order_number' => '1' }
            ],
            'bad' => []
          }
        end

        let(:good_classification) do
          create(:self_care_classification, user: user, order_number: 1, kind: :good)
        end
        let(:normal_classification) do
          create(:self_care_classification, user: user, order_number: 5, kind: :normal)
        end

        it 'グループごとに作成できていること' do
          save!
          # TODO: scopeを設定する
          expect(SelfCareClassification.where(kind: :good).count).to eq(3)
        end
      end
    end

    context 'パラメーターがエラーの場合' do
      context 'パラメーターが足りない場合' do
        let(:params) do
          {
            'good' => [
              { 'id' =>  '',  'name' => 'name1', 'order_number' => 1 }
            ],

            'normal' => [
              { 'id' =>  '',  'name' => 'name1', 'order_number' => 2 }
            ]
          }
        end

        it '例外が発生すること' do
          expect { save! }.to raise_error(SelfCareClassificationsForm::InvalidError)
        end
      end
    end

  end
end
