# frozen_string_literal: true

class SelfCareClassificationsForm
  include ActiveModel::Model

  validate :check_unknown_kind_name
  validate :check_missing_group_names
  validate :check_invalid_params

  def initialize(user, all_group_params)
    @user = user
    @all_group_params = all_group_params
  end

  def save!
    raise SelfCareClassificationsForm::InvalidError, self unless validate

    target_classificaitons = fetch_target_classificaitons
    modified_all_group_params = create_modified_all_group_params

    saver = Saver.new(@user, modified_all_group_params, target_classificaitons)
    saver.save_all_group_classfications

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

  def invalid_params?(param)
    unkonwn_param_names = param.keys - %w[name order_number id]
    some_paramete_not_set = !(param.key?('id') && param.key?('name') && param.key?('order_number'))
    some_paramete_not_set || unkonwn_param_names.present?
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
