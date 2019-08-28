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

  private

  def check_same_order_number
    # データを取得する必要があるので、すでにエラーがある場合はチェックしない
    return if errors.messages.present?
    return if validation_context == :all_update

    relation = SelfCareClassification.where(user_id: user_id, order_number: order_number)
    relation = relation.where.not(id: id) unless new_record?

    errors.add(:order_number, 'すでに同じorder_numberが登録されています') if relation.exists?
  end
end
