# frozen_string_literal: true

## SelfCareClassificationsFormからしか使われないことを想定している

class SelfCareClassificationsForm
  class CreaterSaveTargets
   def initialize(user, all_group_params, target_classificaitons)
    @user = user
    @all_group_params = all_group_params
    @target_classificaitons = target_classificaitons
   end

    def create_all_group_target_classfications
      grouped_targets = @all_group_params.each_with_object({}) do |(kind_name, params), grouped_targets|
        next if params.empty?

        classifications = params.map do |param|
          create_or_assign_attributes_classification(param, kind_name)
        end
        
        grouped_targets[kind_name] = classifications
      end

      grouped_targets
    end

    private 

    def create_classification_assign_attributes(param, kind_name)
      kind_name_sym = kind_name.to_sym

      {
        user: @user, name: param['name'], order_number: param['order_number'],
        kind: kind_name_sym
      }
    end

    def create_or_assign_attributes_classification(param, kind_name)
      if param['id'].present?
        values = create_classification_assign_attributes(param, kind_name)
        classification = @target_classificaitons.find { |c| c.id == param['id'].to_i }
        #別の箇所でバリデーションがかかる
        return nil if classification.nil?
        classification.assign_attributes(values)
      else
        classification = create_classification(param, kind_name)
      end

      classification
    end

    def create_classification(param, kind_name)
      values = create_classification_assign_attributes(param, kind_name)
      SelfCareClassification.new(values)
    end
  end
end
