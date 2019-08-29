# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    subject { build(:user) }

    it { is_expected.to have_many(:self_cares).dependent(:nullify) }
    it { is_expected.to have_many(:self_care_classifications).dependent(:nullify) }
  end

  describe 'Validation' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'need_to_write_log?' do
    let(:user) { create(:user) }

    context '当日の記録の午後' do
      let(:search_date) { DateTime.now.change(hour: 13) }

      it '２回記録している場合はtrueが帰ること' do
        # 未来の記録をするとバリデーションにひっかかるのでバリデーションはおこなわない
        self_care = build(:self_care, user: user, log_date: search_date)
        self_care.save(validate: false)
        self_care = build(:self_care, user: user, log_date: search_date)
        self_care.save(validate: false)

        expect(user).to be_need_to_write_log(search_date)
      end

      it '記録回数が2回未満の場合はfalseが帰ること' do
        # 未来の記録をするとバリデーションにひっかかるのでバリデーションはおこなわない
        self_care = build(:self_care, user: user, log_date: search_date)
        self_care.save(validate: false)

        expect(user).not_to be_need_to_write_log(search_date)
      end
    end

    context '当日の記録の午前' do
      let(:search_date) { DateTime.now.change(hour: 0) }

      it '1回以上記録している場合はtrueが帰ること' do
        create(:self_care, user: user, log_date: search_date)
        expect(user).to be_need_to_write_log(search_date)
      end

      it '1回も記録していない場合はfalseが帰ること' do
        expect(user).not_to be_need_to_write_log(DateTime.now)
      end
    end

    context '昨日の記録の午前' do
      let(:search_date) { DateTime.yesterday.change(hour: 0) }

      it '2回以上記録している場合はtrueが帰ること' do
        create(:self_care, user: user,  log_date: search_date)
        create(:self_care, user: user,  log_date: search_date)

        expect(user).to be_need_to_write_log(search_date)
      end

      it '記録回数が2回未満の場合はfalseが帰ること' do
        create(:self_care, user: user, log_date: search_date)

        expect(user).not_to be_need_to_write_log(search_date)
      end
    end
  end

  describe 'self_care_of_this_week' do
    let(:user) { create(:user) }

    let(:log_dates) do
      [
        DateTime.now,
        DateTime.now - 6.days,
        DateTime.now - 7.days
      ]
    end

    before do
      log_dates.each do |d|
        create(:self_care, user: user, log_date: d)
      end
    end

    it '今週1週間分のセルフケアを取得する' do
      this_week_self_cares = user.self_cares_of_this_week
      expect(this_week_self_cares.count).to eq(2)

      # 古い日付順にソートされている
      expect(this_week_self_cares[0].log_date.day).to eq(log_dates[1].day)
      expect(this_week_self_cares[1].log_date.day).to eq(log_dates[0].day)
    end
  end

  describe 'self_cares_of_this_month' do
    let(:user) { create(:user) }
    let(:this_month_start_day) { Time.zone.now.beginning_of_month }
    let(:log_dates) do
      [
        this_month_start_day.end_of_month,
        this_month_start_day,
        this_month_start_day - 1.month
      ]
    end

    before do
      log_dates.each do |d|
        self_care = build(:self_care, user: user, log_date: d)
        self_care.save(validate: false)
      end
    end

    it '今月の記録を取得する' do
      pp Time.zone

      this_month_self_cares = user.self_cares_of_this_month
      expect(this_month_self_cares.count).to eq(2)
      # 古い日付順にソートされている
      expect(this_month_self_cares[0].log_date.day).to eq(log_dates[1].day)
      expect(this_month_self_cares[1].log_date.day).to eq(log_dates[0].day)
    end
  end

  describe 'fetch_grouping_self_care_classifications' do
    let(:user) { create(:user) }

    before do
      create(:self_care_classification, :good, name: 'name2', user: user, order_number: 2)
      create(:self_care_classification,  :good, name: 'name1', user: user, order_number: 1)

      create(:self_care_classification,  :normal, user: user, order_number: 1)
    end

    it 'kind毎にgroupingかされていること' do
      grouping_classifications = user.fetch_grouping_self_care_classifications
      expect(grouping_classifications.keys).to eq(%w[good normal bad])
    end

    it 'order_number通りに取得できていること' do
      good_classifications = user.fetch_grouping_self_care_classifications['good']
      expect(good_classifications.pluck('name')).to eq(%w[name1 name2])
    end

    it 'データがないkindの場合は空の配列ができていること' do
      bad_classifications = user.fetch_grouping_self_care_classifications['bad']
      expect(bad_classifications).to eq([])
    end
  end
end
