# frozen_string_literal: true

## SelfCareClassificationsFormからしか使われないことを想定している

class SelfCareClassificationsForm
  class Saver
    def initialize(user, all_group_params, target_classificaitons)
      @user = user
      @all_group_params = all_group_params
      @target_classificaitons = target_classificaitons
    end

    def save_all_group_classfications
      @all_group_params.each do |kind_name, params|
        next if params.empty?

        params.each do |param|
          classification = create_or_assign_attributes_classification(param, kind_name)
          classification.save!
        end
      end
    end

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
