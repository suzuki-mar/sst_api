# frozen_string_literal: true

class SelfCareClassificationsForm
  include ActiveModel::Model

  validate :check_input_params
  # 最後に実行する
  validate :check_classifications_validate

  def initialize(user, all_group_params)
    @all_group_params = all_group_params
    @creator = CreaterSaveTargets.new(user, all_group_sorted_params, target_classificaitons)
    @all_group_target_classfications = @creator.create
    @validate_executor = ValidateExecutor.new(
      user, @all_group_params, @all_group_target_classfications
    )
  end

  def save!
    raise SelfCareClassificationsForm::InvalidError, self unless validate

    @all_group_target_classfications.each do |_kind_name, classifications|
      classifications.each do |classification|
        classification.save!(context: :all_update)
      end
    end

    true
  end

  class InvalidError < StandardError
    def initialize(form)
      @form = form
    end
  end

  private

  def create_all_group_sorted_params
    all_group_sorted_params = {}
    @all_group_params.each do |kind_name, params|
      all_group_sorted_params[kind_name] = params.empty? ? [] : create_modified_params(params)
    end

    all_group_sorted_params
  end

  def create_modified_params(params)
    sorted_params = params.sort_by { |param| param['order_number'] }
    sorted_params.map.with_index do |param, index|
      { 'id' => param['id'], 'name' => param['name'], 'order_number' => index + 1 }
    end
  end

  def fetch_target_classificaitons
    ids = @all_group_params.each_with_object([]) do |(_kind_name, params), array|
      array.concat(params.pluck('id'))
    end
    ids = ids.reject(&:blank?)
    SelfCareClassification.where(id: ids)
  end

  VALIDATE_PARAMS = [
    {
      method_name_sym: :create_invalid_kind_names_of_unknow_kind_names,
      base_error_message: '不正な項目名が渡されました',
      error_key: :kind_name
    },
    {
      method_name_sym: :create_invalid_kind_names_of_missing_kind_names,
      base_error_message: '足りない項目名があります',
      error_key: :kind_name
    },
    {
      method_name_sym: :create_invalid_kind_names_of_unknown_classification_ids,
      base_error_message: '不正なIDが渡された項目があります',
      error_key: :params
    },
    {
      method_name_sym: :create_invalid_kind_names_of_invalid_params,
      base_error_message: '不正なパラメーターが渡された項目があります',
      error_key: :params
    },
    {
      method_name_sym: :create_invalid_kind_names_of_not_exists_same_order_number,
      base_error_message: '同じ順番が設定されています',
      error_key: :params
    },
    {
      method_name_sym: :create_invalid_kind_names_of_not_exists_same_name,
      base_error_message: '同じ名前が設定されています',
      error_key: :params
    }
  ].freeze

  def check_input_params
    VALIDATE_PARAMS.each do |param|
      check_by_validate_param(param)
    end
  end

  def check_classifications_validate
    # 最終チェックなのですでにエラーがある場合は実行しない
    return if errors.messages.present?

    validate_param = {
      method_name_sym: :create_invalid_kind_names_of_classifications_validate,
      base_error_message: 'バリデーションエラーが発生しました',
      error_key: :params
    }

    check_by_validate_param(validate_param)
  end

  def check_by_validate_param(validate_param)
    method_name = validate_param[:method_name_sym]
    validate_mehotd_reponsed = @validate_executor.respond_to?(method_name)
    raise StandardError, "#{method_name}を実装してください" unless validate_mehotd_reponsed

    invalid_kind_names = @validate_executor.send(method_name)
    return if invalid_kind_names.blank?

    error_message = create_error_messages_with_kind_names(
      validate_param[:base_error_message], invalid_kind_names
    )
    errors.add(validate_param[:error_key], error_message)
  end

  def target_classificaitons
    @target_classificaitons ||= fetch_target_classificaitons
  end

  def all_group_sorted_params
    @all_group_sorted_params ||= create_all_group_sorted_params
  end

  def create_error_messages_with_kind_names(base_message, kind_names)
    error_message = "#{base_message}:"
    kind_names.each do |name|
      error_message += "#{name},"
    end
    error_message.slice!(-1)
    error_message
  end
end
