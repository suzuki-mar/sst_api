# frozen_string_literal: true

FactoryBot.define do
  factory :self_care do
    self_care_classification
    user
    log_date { "2019-08-06" }
    reason { "MyText" }
    point { 8 }
  end
end
