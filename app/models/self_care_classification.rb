# frozen_string_literal: true

class SelfCareClassification < ApplicationRecord
  belongs_to :user

  validates :name, presence: true
  
  enum kind: {good: 1, normal: 2,  bad: 3}
end
