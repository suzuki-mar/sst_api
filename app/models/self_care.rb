# frozen_string_literal: true

class SelfCare < ApplicationRecord
  belongs_to :self_care_classification
  belongs_to :user

  validates :point, inclusion: { in: 1..10 }, presence: true
  validates :reason, presence: true
  validate :validate_of_not_future_log

  validate :check_user_id_and_classification_user_id_same

  private

  def check_user_id_and_classification_user_id_same
    return if user_id.nil? || self_care_classification.nil?

    message = 'user_idとself_care_classificationのuser_idが同一ではありません'
    errors.add(:self_care_classification, message) if user_id != self_care_classification.user_id
  end

  def validate_of_not_future_log
    errors.add(:log_date, '未来の日付にはできません') if DateTime.now < log_date
  end
end
