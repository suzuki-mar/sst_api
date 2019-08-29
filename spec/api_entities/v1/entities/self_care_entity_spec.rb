# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V1::Entities::SelfCareEntity, type: :model do
  let(:entity) do
    log_date = Time.zone.local(2012, 6, 30, 23, 59, 0, 0)
    self_care = create(:self_care, log_date: log_date)

    described_class.new(self_care)
  end

  it '必要なキーがすべて持っていること' do
    expected_keys = %i[id self_care_classification_id user_id reason log_date point]
    expect(entity.as_json.keys).to eq(expected_keys)
  end

  it 'log_dateはyyyy-MM-dd HH:mmになっていること' do
    expect(entity.as_json[:log_date]).to eq('2012-06-30 23:59')
  end
end
