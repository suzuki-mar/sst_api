#TODO データが多くなってきたらファイル分割する
User.seed do |s|
  s.id = 1
  s.name = 'Test User'
end

SelfCareClassification.seed do |s|
  s.name = "仕事が楽しい"
  s.order_number = 1
  s.kind = 1
end
