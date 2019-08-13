require 'rails_helper'

RSpec.describe SelfCare, type: :model do

  describe 'associations' do
    subject{build(:self_care)}

    it { should belong_to(:self_care_classification) }
    it { should belong_to(:user) }
  end
   
  describe 'Validation' do 
    subject{build(:self_care)}

    it {should validate_inclusion_of(:point).in_range(1..10)}
    it {should validate_presence_of(:point)}
    it {should validate_presence_of(:reason)}

    describe 'log_dateのフォーマットチェック' do
      context '過去' do 
        it 'バリデーションが通ること' do
          self_care = build(:self_care, log_date: DateTime.now)
          expect(self_care.valid?).to be_truthy
        end
      end
      
      context '未来' do
        it "バリデーションエラーとなること" do
          log_date = DateTime.now + 1.seconds 
          self_care = build(:self_care, log_date: log_date)
          expect(self_care.valid?).to be_falsy
          expect(self_care.errors.messages[:log_date]).to eq(['未来の日付にはできません'])
        end

      end
    end
  end

end
