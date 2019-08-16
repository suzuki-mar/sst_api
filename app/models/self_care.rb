# frozen_string_literal: true

class SelfCare < ApplicationRecord
  belongs_to :self_care_classification
  belongs_to :user

  validates :point, inclusion: { in: 1..10 }, presence: true
  validates :reason, presence: true
  validate :validate_of_not_future_log

  private

  def validate_of_not_future_log
    errors.add(:log_date, "未来の日付にはできません") if DateTime.now < log_date
   end
end
