# frozen_string_literal: true

class User < ApplicationRecord
  # userが存在しなくなっても,self_care_classificationから参照する可能性があるので削除はしない
  has_many :self_cares, dependent: :nullify
  has_many :self_care_classifications, dependent: :nullify

  validates :name, presence: true

  def need_to_write_log?(search_datetime)
    today_afternoon = (
      search_datetime.day == Time.zone.today.day &&
      search_datetime.hour < 13
    )
    expectation_count = today_afternoon ? 1 : 2

    search_range = search_datetime.beginning_of_day..search_datetime.end_of_day
    self_cares.where(log_date: search_range).count >= expectation_count
  end

  def self_cares_of_this_week
    this_week_start_day = Time.zone.now - 6.days
    search_range = this_week_start_day.beginning_of_day..DateTime.now.end_of_day
    self_cares.where(log_date: search_range).order('log_date ASC')
  end

  def self_cares_of_this_month
    start_date = Time.zone.now.beginning_of_month
    end_date = Time.zone.now.end_of_month
    search_range = start_date.beginning_of_day..end_date
    self_cares.where(log_date: search_range).order('log_date ASC')
  end
end
