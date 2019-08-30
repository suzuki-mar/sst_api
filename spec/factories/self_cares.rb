# frozen_string_literal: true

FactoryBot.define do
  factory :self_care do
    user
    log_date { '2019-08-06' }
    reason { 'MyText' }
    point { 8 }

    before(:create) do |self_care|
      if self_care.self_care_classification.nil?
        self_care.self_care_classification = create(:self_care_classification, user: self_care.user) 
      end
    end

  end
end
