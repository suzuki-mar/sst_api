# frozen_string_literal: true

module V1
  class SelfCareClassifications < Grape::API
    resources :self_care_classifications do
      desc "セルフケアの分類一覧を取得する",
           is_array: true,
           success: V1::Entities::SelfCareClassificationEntity
      get "/" do
        @classifications = SelfCareClassification.all
        present @classifications, with: V1::Entities::SelfCareClassificationEntity
      end
    end
  end
end
