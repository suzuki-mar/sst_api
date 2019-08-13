require 'rails_helper'

RSpec.describe User, type: :model do
  
  describe 'associations' do
    subject{build(:user)}

    it { should have_many(:self_cares).dependent(:nullify) }
  end

  describe 'Validation' do 
    subject{build(:user)}

    it {should validate_presence_of(:name)}
  end

  describe 'need_to_write_log?' do 
    let(:user){create(:user)}
    
  context '当日の記録の午後' do
      let(:search_date){DateTime.now.change(hour: 13)}

      it '２回記録している場合はtrueが帰ること' do
        # 未来の記録をするとバリデーションにひっかかるのでバリデーションはおこなわない
        self_care = build(:self_care, user: user,  log_date: search_date)
        self_care.save(validate: false)
        self_care = build(:self_care, user: user,  log_date: search_date)
        self_care.save(validate: false)
  
        expect(user.need_to_write_log?(search_date)).to be_truthy
      end

      it '記録回数が2回未満の場合はfalseが帰ること' do
        # 未来の記録をするとバリデーションにひっかかるのでバリデーションはおこなわない
        self_care = build(:self_care, user: user,  log_date: search_date)
        self_care.save(validate: false)
  
        expect(user.need_to_write_log?(search_date)).to be_falsey
      end
    end

    context '当日の記録の午前' do
      let(:search_date){DateTime.now.change(hour: 0)}

      it '1回以上記録している場合はtrueが帰ること' do
        create(:self_care, user: user,  log_date: search_date)
        expect(user.need_to_write_log?(search_date)).to be_truthy
      end
  
      it '1回も記録していない場合はfalseが帰ること' do
        expect(user.need_to_write_log?(DateTime.now)).to be_falsey
      end
    end

    context '昨日の記録の午前' do
      let(:search_date){DateTime.yesterday.change(hour: 0)}

      it '2回以上記録している場合はtrueが帰ること' do
        create(:self_care, user: user,  log_date: search_date)
        create(:self_care, user: user,  log_date: search_date)

        expect(user.need_to_write_log?(search_date)).to be_truthy
      end
  
      it '記録回数が2回未満の場合はfalseが帰ること' do
        create(:self_care, user: user,  log_date: search_date)
        
        expect(user.need_to_write_log?(search_date)).to be_falsey
      end
    end
    
  end

  describe 'self_care_of_this_week' do
    let(:user){create(:user)}

    it '今週1週間分のセルフケアを取得する' do

      log_dates = [
        DateTime.now,
        DateTime.now - 6.day,
        DateTime.now - 7.day
      ]
      
      log_dates.each do |d|
        create(:self_care, user: user, log_date:d)
      end
      
      this_week_self_cares = user.self_cares_of_this_week
     expect(this_week_self_cares.count).to eq(2)   

      # 古い日付順にソートされている
      expect(this_week_self_cares[0].log_date.day).to eq(log_dates[1].day)
      expect(this_week_self_cares[1].log_date.day).to eq(log_dates[0].day)
      
    end
  end
  
  describe 'self_cares_of_this_month' do 
    let(:user){create(:user)}

    it '今月の記録を取得する' do

     this_month_start_day =  DateTime.now.beginning_of_month

      log_dates = [
       this_month_start_day.end_of_month,
       this_month_start_day,
       this_month_start_day - 1.month
      ]
      
      log_dates.each do |d|
        self_care = build(:self_care, user: user, log_date:d)
        self_care.save(validate: false)
      end
      
    this_month_self_cares = user.self_cares_of_this_month
     expect(this_month_self_cares.count).to eq(2)   

      # 古い日付順にソートされている
      expect(this_month_self_cares[0].log_date.day).to eq(log_dates[1].day)
      expect(this_month_self_cares[1].log_date.day).to eq(log_dates[0].day)
      
    end

  end

end
