# frozen_string_literal: true

module V1
  class SelfCares < Grape::API
    resources :self_cares do
      desc '直近のセルフケアを取得する',
           is_array: true,
           success: V1::Entities::SelfCareEntity
      get '/recent' do
        self_cares = current_user.self_cares_of_recent

        present self_cares,
                with: V1::Entities::SelfCareEntity
      end
    end
  end
end
