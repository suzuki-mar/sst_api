# frozen_string_literal: true

class SelfCareClassification < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  # ユニークかはメソッドでチェックをする
  validates :order_number, presence: true
  validate :check_same_order_number

  enum kind: {good: 1, normal: 2,  bad: 3}

  private

  def check_same_order_number
    # データを取得する必要があるので、すでにエラーがある場合はチェックしない
    return if errors.messages.present?
    return if validation_context == :all_update

    relation = SelfCareClassification.where(user_id: self.user_id, order_number: self.order_number)
    unless  new_record?
      relation = relation.where.not(id: self.id)
    end

    if relation.exists?
      errors.add(:order_number, 'すでに同じorder_numberが登録されています')
    end
  end

end
