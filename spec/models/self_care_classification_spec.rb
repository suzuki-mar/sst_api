# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SelfCareClassification, type: :model do
  describe 'associations' do
    subject { build(:self_care_classification) }

    it { is_expected.to belong_to(:user) }
  end
end
