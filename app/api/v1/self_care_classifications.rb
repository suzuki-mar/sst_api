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
        def create_form(input_param)
          update_params = {}
        # 空のハッシュを送信すると空文字がセットされる
          params[:input_params][0].each do |kind_name, params|
            update_params[kind_name] = params[0].present? ?  params : []
          end

          update_params.each do |kind_name, params|
            next if params.blank?

            params.each do |param|
              param["id"] =  param["id"].present? ?  param["id"].to_i : ''
              param["order_number"] =   param["order_number"].to_i
            end

          end
          SelfCareClassificationsForm.new(current_user, update_params)  
        end

        # 1人のユーザーしか使わない想定
        def current_user
         user = User.last
        end

        def create_error_message_from_model(model)
          error_message = model.errors.messages.reduce('') do |message, (name, msgs)|
            message += "#{name}:"  
            msgs.each do |msg|
              message += "#{msg},"
            end
            message.slice!(-1)
            message += "\n"  
          end
          error_message.slice!(-1)
          error_message
        end
        
      end
  
      desc 'セルフケア分類をまとめて設定する 戻り値ResultResponse'
      params do
        desc = "入力データ TODO パラメーターの詳細をドキュメントに書く"
        requires :input_params, type: Array, desc: desc
      end
      post '/group' do
        form = create_form(params[:input_params])

        if  !form.validate 
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
