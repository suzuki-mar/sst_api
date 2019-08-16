# frozen_string_literal: true

module V1
  module Entities
    class SelfCareClassificationEntity < Grape::Entity
      expose :id, documentation: { type: "integer", required: true, desc: "ID" }
      expose :name, documentation: { type: "string", required: true, desc: "分類名" }
      expose :order_number, documentation: { type: "integer", required: true, desc: "表示番号" }
      expose :kind, documentation: { type: "integer", required: true, desc: "分類ID 後でkind_textに置き換える" }
    end
  end
end
