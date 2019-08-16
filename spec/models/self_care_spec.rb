# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelfCare, type: :model do
  describe 'associations' do
    subject { build(:self_care) }

    it { is_expected.to belong_to(:self_care_classification) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'Validation' do
    subject { build(:self_care) }

    it { is_expected.to validate_inclusion_of(:point).in_range(1..10) }
    it { is_expected.to validate_presence_of(:point) }
    it { is_expected.to validate_presence_of(:reason) }

    describe 'log_dateのフォーマットチェック' do
      context '過去' do
        it 'バリデーションが通ること' do
          self_care = build(:self_care, log_date: DateTime.now)
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
