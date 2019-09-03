# frozen_string_literal: true

module V1
  class SelfCares < Grape::API
    resources :self_cares do
      desc 'セルフケアを登録する'
      params do
        desc = '入力データ'
        requires :input_params, type: Array, desc: desc
      end
      post '/' do
        param = params['input_params'][0]
        classificaiton_id = param['self_care_classification_id']

        unless SelfCareClassification.exists?(classificaiton_id)
          error!('存在しない分類に登録しようとしました', 400)
          return
        end

        classificaiton = SelfCareClassification.find(param['self_care_classification_id'].to_i)

        self_care = SelfCare.new(log_date: param[:log_date], reason: param[:reason],
                                 point: param[:point], user_id: current_user.id,
                                 self_care_classification_id: classificaiton.id)

        unless self_care.validate
          error_message = create_error_message_from_model(self_care)
          error!(error_message, 400)
          return
        end

        self_care.save!

        status 204
      end

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
