# frozen_string_literal: true

# TODO: データが多くなってきたらファイル分割する
User.seed do |s|
  s.id = 1
  s.name = 'Test User'
end

SelfCareClassification.seed do |s|
  s.user = User.find(1)
  s.name = '仕事が楽しい'
  s.order_number = 1
  s.kind = 1
end

SelfCare.seed do |s|
  s.user = User.find(1)
  s.self_care_classification = SelfCareClassification.find(1)
  s.log_date = Time.zone.yesterday
  s.reason = '順調にタスクが進んでいるため'
  s.point = 2
end
