# frozen_string_literal: true

module V1
  module Entities
    class SelfCareEntity < Grape::Entity
      expose :id, documentation: {
        type: 'integer',
        required: true
      }

      expose :self_care_classification_id, documentation: {
        type: 'integer',
        required: true
      }

      expose :user_id, documentation: {
        type: 'integer',
        required: true
      }

      expose :reason, documentation: {
        type: 'integer',
        required: true,
        desc: '体調の理由'
      }

      expose :log_date, documentation: {
        type: 'date_time',
        required: true,
        desc: 'ログの日付'
      } do |status, _options|
        status.log_date.strftime('%Y-%m-%d %H:%M')
      end

      expose :point, documentation: {
        type: 'integer',
        required: true,
        desc: '体調 数字が小さいほど悪い'
      }
    end
  end
end
