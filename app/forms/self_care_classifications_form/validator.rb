# frozen_string_literal: true

## SelfCareClassificationsFormからしか使われないことを想定している

class SelfCareClassificationsForm
  class Validator
    def initialize(user, all_group_params, all_group_target_classfications)
      @user = user
      @all_group_params = all_group_params
      @all_group_target_classfications = all_group_target_classfications
    end

    def create_invalid_kind_names_of_unknow_kind_names
      @all_group_params.keys - SelfCareClassification.kinds.keys
    end

    def create_invalid_kind_names_of_missing_kind_names
      SelfCareClassification.kinds.keys - @all_group_params.keys
    end

    def create_invalid_kind_names_of_unknown_classification_ids
      registered_classification_ids = SelfCareClassification.where(user: @user).pluck(:id)

      @all_group_params.each_with_object([]) do |(kind_name, params), kind_names|
        ids = params.pluck('id').reject(&:blank?)
        kind_names << kind_name if (ids - registered_classification_ids).present?
      end
    end

    def create_invalid_kind_names_of_invalid_params
      @all_group_params.each_with_object([]) do |(kind_name, params), array|
        invalid = params.any? { |param| invalid_params?(param) }
        array << kind_name if invalid
      end
    end

    def create_invalid_kind_names_of_not_exists_same_order_number
      @all_group_params.each_with_object([]) do |(kind_name, params), kind_names|
        order_numbers = params.pluck('order_number')
        exists_same_order_number = (order_numbers.count - order_numbers.uniq.count).positive?
        kind_names << kind_name if exists_same_order_number
      end
    end

    def create_invalid_kind_names_of_classifications_validate
      # 一時的に変数名を短くするため
      target_classfications = @all_group_target_classfications
      target_classfications.each_with_object([]) do |(kind_name, classifications), kind_names|
        invalid = classifications.any? do |classification|
          !classification.validate(:all_update)
        end

        next unless invalid

        kind_names << kind_name
      end
    end

    private

    def invalid_params?(param)
      unkonwn_param_names = param.keys - %w[name order_number id]
      some_paramete_not_set = %w[id name order_number].any? { |key_name| !param.key?(key_name) }
      some_paramete_not_set || unkonwn_param_names.present?
    end
  end
end
