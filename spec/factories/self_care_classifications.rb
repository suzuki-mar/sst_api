# frozen_string_literal: true

FactoryBot.define do
  factory :self_care_classification do
    user
    name { 'MyString' }
    order_number { 1 }
    kind {:bad}
  end
end
