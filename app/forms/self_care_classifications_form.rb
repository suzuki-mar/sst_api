# frozen_string_literal: true

class SelfCareClassificationsForm
  include ActiveModel::Model

  validate :check_unknown_kind_name
  validate :check_missing_group_names
  validate :check_invalid_params
  validate :check_classification_ids_of_not_registered
  validate :check_not_exists_same_order_number
  validate :check_classifications_validate

  def initialize(user, all_group_params)
    @user = user
    @all_group_params = all_group_params
  end

  # TODO save on rollback if errorに変更する
  def save!
    raise SelfCareClassificationsForm::InvalidError, self unless validate
    creator = CreaterSaveTargets.new(@user, modified_all_group_params, target_classificaitons)
    group_classifications =  creator.create_all_group_target_classfications

    group_classifications.each do |kind_name, classifications|
      classifications.each do |classification|
        classification.save!
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
  def create_modified_all_group_params
    modified_all_group_params = {}
    @all_group_params.each do |kind_name, params|
      modified_all_group_params[kind_name] = if params.empty?
                                               []
                                             else
                                               create_modified_params(params)
                                             end
    end

    modified_all_group_params
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

  def check_unknown_kind_name
    unkonwn_kind_names = @all_group_params.keys - SelfCareClassification.kinds.keys
    return if unkonwn_kind_names.blank?

    error_message = create_error_messages_with_kind_names(
      '不正な項目名が渡されました', unkonwn_kind_names
    )

    errors.add(:kind_name, error_message)
  end

  def check_missing_group_names
    missing_kind_names = SelfCareClassification.kinds.keys - @all_group_params.keys
    return if missing_kind_names.blank?

    error_message = '足りない項目名があります:'
    missing_kind_names.each do |name|
      error_message += "#{name},"
    end
    error_message.slice!(-1)

    errors.add(:kind_name, error_message)
  end

  def check_classification_ids_of_not_registered
    registered_classification_ids = SelfCareClassification.where(user: @user).pluck(:id)

    invalid_kind_names = @all_group_params.each_with_object([]) do |(kind_name, params), invalid_kind_names|
      ids = params.pluck('id').reject(&:blank?)
      invalid_kind_names << kind_name if (ids - registered_classification_ids).present?
    end

    return if invalid_kind_names.blank?

    error_message = create_error_messages_with_kind_names(
      '不正なIDが渡された項目があります', invalid_kind_names
    )
    errors.add(:params, error_message)
  end

  def check_invalid_params
    invalid_kind_names = @all_group_params.each_with_object([]) do |(kind_name, params), array|
      invalid = params.any? { |param| invalid_params?(param) }
      array << kind_name if invalid
    end

    return if invalid_kind_names.blank?

    error_message = create_error_messages_with_kind_names(
      '不正なパラメーターが渡された項目があります', invalid_kind_names
    )
    errors.add(:params, error_message)
  end

  def check_not_exists_same_order_number
    invalid_kind_names = @all_group_params.each_with_object([]) do |(kind_name, params), kind_names|
      order_numbers = params.pluck('order_number')
      exists_same_order_number = (order_numbers.count - order_numbers.uniq.count) > 0
      kind_names << kind_name if exists_same_order_number
    end

    return if invalid_kind_names.blank?

    error_message = create_error_messages_with_kind_names(
      '同じ順番が設定されています', invalid_kind_names
    )
    errors.add(:params, error_message)
  end

  def check_classifications_validate

    # 最終チェックなのですでにエラーがある場合は実行しない
   return if self.errors.messages.present?
   
    creator = CreaterSaveTargets.new(@user, modified_all_group_params, target_classificaitons)
    invalid_kind_names = creator.create_all_group_target_classfications.each_with_object([]) do |(kind_name, classifications), kind_names| 
      
      invalid = classifications.any?{|classification| !classification.validate}
      next unless invalid
      kind_names << kind_name
    end

    return if invalid_kind_names.blank?

    error_message = create_error_messages_with_kind_names(
      'バリデーションエラーが発生しました', invalid_kind_names
    )
    errors.add(:params, error_message)
  end

  def invalid_params?(param)
    unkonwn_param_names = param.keys - %w[name order_number id]
    some_paramete_not_set = !(param.key?('id') && param.key?('name') && param.key?('order_number'))
    some_paramete_not_set || unkonwn_param_names.present?
  end

  def target_classificaitons
    @target_classificaitons = @target_classificaitons || fetch_target_classificaitons
  end
  
  def modified_all_group_params
    @modified_all_group_params = @modified_all_group_params || create_modified_all_group_params
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
