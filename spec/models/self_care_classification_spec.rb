# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelfCareClassification, type: :model do
  describe 'associations' do
    subject { build(:self_care_classification) }

    it { is_expected.to belong_to(:user) }
  end

  describe 'scope' do
    let(:user){create(:user)}
    before :each do
      create(:self_care_classification, user: user, kind: :good)
      create(:self_care_classification, user: user, kind: :good)
      create(:self_care_classification, user: user, kind: :bad)
    end
    
    describe 'kind_by' do
      it '指定したkindを取得できる' do
        expect(SelfCareClassification.kind_by(:good).count).to eq(2)
      end
      it '不正なパラメーターが渡されたらArugmetErrorになる' do
        expect { SelfCareClassification.kind_by(:unknown) }.to raise_error(ArgumentError)
      end
    end
  end
  
  describe 'Validation' do
    subject { build(:self_care_classification) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:order_number) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to([:user_id, :kind]) }

    describe 'order_numberの重複チェック' do
      let(:user){create(:user)}
      before do
        create(:self_care_classification, kind: :good, user:user, order_number:1)
      end

      context 'contextがall_update以外の場合' do
        let(:another_user){create(:user)}

        it '違うユーザーの同じkindで同じorder_numberの場合はバリデーションエラーにならない' do
          classification = build(:self_care_classification, kind: :good, order_number:1, user: another_user)
          expect(classification.validate).to be_truthy
        end

        it '同じユーザーの同じkindで同じorder_numberの場合はエラーとなる' do
          classification = build(:self_care_classification, kind: :good, user:user, order_number:1)
          expect(classification.validate).to be_falsy
        end

        it '同じユーザーの同じkindで同じorder_numberの場合でも同じIDの場合はエラーとならない' do
          classification = create(:self_care_classification, kind: :good, user:user, order_number:2)
          expect(classification.validate).to be_truthy
        end

      end

      context 'contextがall_updateの場合' do
        it 'contextがall_updateの場合はorder_numberをバリデーションチェックしない' do
          classification = build(:self_care_classification, kind: :good, user:user, order_number:1)
          expect(classification.validate(:all_update)).to be_truthy
        end
      end

    end
  end

  describe 'enum' do
    subject { build(:self_care_classification) }

    it do 
      should define_enum_for(:kind).with_values(good: 1, normal: 2, bad: 3)
    end

  end

end
