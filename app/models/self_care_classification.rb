# frozen_string_literal: true

class SelfCareClassification < ApplicationRecord
  enum kind: {good: 1, normal: 2,  bad: 3}

  belongs_to :user
end
