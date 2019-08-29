# frozen_string_literal: true

module V1
  class SelfCareClassifications < Grape::API
    resources :self_care_classifications do
      desc 'セルフケアの分類一覧を取得する',
           is_array: true,
           success: V1::Entities::SelfCareClassificationEntity
      get '/' do
        @classifications = SelfCareClassification.all
        present @classifications,
                with: V1::Entities::SelfCareClassificationEntity
      end

      helpers do
        def create_grouping_entities(grouping_classificaitons)
          grouping_entities = {}
          grouping_classificaitons.each do |kind_name, classifications|
            grouping_entities[kind_name] = []
            classifications.each do |classificaiton|
              entity = V1::Entities::SelfCareClassificationEntity.new(classificaiton)
              grouping_entities[kind_name] << entity
            end
          end

          grouping_entities
        end
      end

      desc 'セルフケア分類をまとめて取得する'
      get '/group' do
        grouping_self_care_classificaitons = current_user.fetch_grouping_self_care_classifications
        grouping_entities = create_grouping_entities(grouping_self_care_classificaitons)
        present grouping_entities
      end

      helpers do
        def create_form(_input_param)
          update_params = {}
          # 空のハッシュを送信すると空文字がセットされる
          params[:input_params][0].each do |kind_name, params|
            update_params[kind_name] = params[0].present? ? params : []
          end

          update_params = create_update_param_of_casted_param(update_params)
          SelfCareClassificationsForm.new(current_user, update_params)
        end

        def create_update_param_of_casted_param(update_params)
          update_params.each do |_kind_name, params|
            next if params.blank?

            params.each do |param|
              param['id'] = param['id'].present? ? param['id'].to_i : ''
              param['order_number'] = param['order_number'].to_i
            end
          end

          update_params
        end
      end

      desc 'セルフケア分類をまとめて設定する 戻り値ResultResponse'
      params do
        desc = '入力データ TODO パラメーターの詳細をドキュメントに書く'
        requires :input_params, type: Array, desc: desc
      end
      post '/group' do
        form = create_form(params[:input_params])

        unless form.validate
          error_message = create_error_message_from_model(form)
          error!(error_message, 400)
          return
        end

        form.save!
        status 204

        result_response = ResultResponse.new('success')
        present result_response.to_respnose
      end
    end
  end
end
