# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelfCare, type: :model do
  describe 'associations' do
    subject { 
     self_care =  create(:self_care) 
    #  pp self_care
    #  pp self_care.validate
    #  exit
     self_care
     
    }

    it {
      # pp subject
      # pp subject.validate
      
       is_expected.to belong_to(:self_care_classification)
      }
    it { is_expected.to belong_to(:user) }
  end

  describe 'Validation' do
    subject { create(:self_care) }

    it { is_expected.to validate_inclusion_of(:point).in_range(1..10) }
    it { is_expected.to validate_presence_of(:point) }
    it { is_expected.to validate_presence_of(:reason) }

    describe 'self_care_classification_id' do
      let(:user){create(:user)}

      context 'userに所属しているself_care_classificationの場合' do
        let(:classification){create(:self_care_classification, user: user)}

        it 'バリデーションが通ること' do
          self_care = build(:self_care, user: user, self_care_classification: classification)
          expect(self_care).to be_valid
        end
      end

       context 'userに所属していないself_care_classificationの場合' do
          let(:another_user_classification){create(:self_care_classification)}

          it 'バリデーションが通らないこと' do
            self_care = build(:self_care,  user: user, self_care_classification: another_user_classification)
            expect(self_care).not_to be_valid
            expected_message = "user_idとself_care_classificationのuser_idが同一ではありません"
            expect(self_care.errors.messages[:self_care_classification]).to eq([expected_message])
          end
      end
    end

    describe 'log_dateのバリデーションチェック' do
      context '過去' do
        it 'バリデーションが通ること' do
          self_care = create(:self_care, log_date: DateTime.now)
          expect(self_care).to be_valid
        end
      end

      context '未来' do
        it 'バリデーションエラーとなること' do
          log_date = DateTime.now + 1.second
          self_care = build(:self_care, log_date: log_date)
          expect(self_care).not_to be_valid
          expect(self_care.errors.messages[:log_date]).to eq(['未来の日付にはできません'])
        end
      end
    end
  end
end
