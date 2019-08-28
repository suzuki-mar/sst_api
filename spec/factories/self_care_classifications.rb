# frozen_string_literal: true

FactoryBot.define do
  factory :self_care_classification do
    user
    sequence(:name) { |n| "classification#{n}" }
    sequence(:order_number) { |n| "#{n}" }
    kind {:bad}
  end
end
