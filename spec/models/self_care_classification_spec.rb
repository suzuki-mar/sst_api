# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelfCareClassification, type: :model do
  describe 'associations' do
    subject { build(:self_care_classification) }

    it { is_expected.to belong_to(:user) }
  end

  describe 'Validation' do
    subject { build(:self_care_classification) }
    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'enum' do
    subject { build(:self_care_classification) }

    it do 
      should define_enum_for(:kind).with_values(good: 1, normal: 2, bad: 3)
    end

  end

end
