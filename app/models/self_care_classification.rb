# frozen_string_literal: true

class SelfCareClassification < ApplicationRecord
  belongs_to :user

  validates :name, presence: true, uniqueness: { scope: %i[user_id kind] }
  # ユニークかはメソッドでチェックをする
  validates :order_number, presence: true
  validate :check_same_order_number

  enum kind: { good: 1, normal: 2, bad: 3 }

  scope :kind_by, lambda { |kind|
    raise ArgumentError, 'kindの値を渡しください' unless kinds.keys.include?(kind.to_s)

    where(kind: kind)
  }

  scope :ordered, -> { order('order_number ASC') }

  private

  def check_same_order_number
    # データを取得する必要があるので、すでにエラーがある場合はチェックしない
    return if errors.messages.present?
    return if validation_context == :all_update

    message = 'すでに同じorder_numberが登録されています'
    errors.add(:order_number, message) if SelfCareClassification.exists_same_order_number?(self)
  end

  class << self
    def exists_same_order_number?(record)
      relation = where(
        user_id: record.user_id, order_number: record.order_number, kind: record. kind
      )

      relation = relation.where.not(id: record.id) unless record.new_record?

      relation.exists?
    end
  end
end
