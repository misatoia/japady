# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


# 管理者
admins = [
    {name: "煌木太郎", nickname: "太郎", email: "taro@techacademy.jp", \
        area_of_residence: "中央地区", purpose: "団体を支援する"},
    {name: "煌木三郎", nickname: "三郎", email: "saburo@techacademy.jp", \
        area_of_residence: "中央地区２", purpose: "兄を支援する"},
]
admins.each do | user |
  timestamp = Time.zone.now - 120.days
  user['password'] = 'password'
  user['admin'] = true
  user['member'] = true
  user['created_at'] = timestamp
  user['updated_at'] = timestamp
end
User.create(admins)

# 教室代表
managers = [
  {name: "月島みどり", nickname: "マンデー会 月島", email: "tsukishima@example.jp", \
      area_of_residence: "北地区", purpose: "人のつながりをひろげる"},
  {name: "水谷 孝雄", nickname: "水曜教室 水谷", email: "mizutani@example.jp", \
      area_of_residence: "南地区", purpose: "日本とこの街のすばらしさを多くの外国人に伝えたい"},
  {name: "木村 浩一", nickname: "日本語クラブ 木村", email: "kimura@example.jp", \
      area_of_residence: "南地区", purpose: "生活困難者をゼロにする"},
  {name: "土橋 順子", nickname: "Satties 土橋", email: "dobashi@example.jp", \
      area_of_residence: "東町", purpose: "私ができることで貢献したい"}
]
managers.each do | user |
  timestamp = Time.zone.now + rand(-100..-50).days
  user['password'] = 'password'
  user['manager'] = true
  user['member'] = true
  user['created_at'] = timestamp
  user['updated_at'] = timestamp
  user['authorized_at'] = timestamp
  user['authorized_by_id'] = User.find_by(admin: true).id
end
mon, wed, thu, sat = User.create(managers)



# 利用者
members = [
  {name: "John Lemon", nickname: "John", email: "john@example.com", \
      area_of_residence: "Minami", purpose: "I'd love to work for this city."},
  {name: "Smith Strawberry", nickname: "Smith", email: "smith@example.com", \
      area_of_residence: "Kita", purpose: "Learn anything"},
  {name: "Owen Vinegar", nickname: "Owen", email: "owen@example.com", \
      area_of_residence: "Chuo", purpose: "Learn anything"},
  {name: "Ambrose Nyaga", nickname: "Ambo", email: "ambo@example.com", \
      area_of_residence: "Chuo", purpose: ""},
  {name: "Kyoko Beeton", nickname: "Kyoko", email: "kyoko@example.com", \
      area_of_residence: "Higashi", purpose: "Live in Japan."},
  {name: "Chris Beeton", nickname: "Chris", email: "chris@example.com", \
      area_of_residence: "Higashi", purpose: "Live in Japan."},
  {name: "Andrew Yamaguchi", nickname: "Andy", email: "andy@example.com", \
      area_of_residence: "Minami", purpose: "To explore cultural environment"},
  {name: "Elizabeth Nguru", nickname: "Liz", email: "nguru@example.com", \
      area_of_residence: "Kita", purpose: ""},

  {name: "Kawai", nickname: "kawai", email: "kawai@example.jp", \
      area_of_residence: "東地区", purpose: "Help each other"},
  {name: "Mori", nickname: "morimori", email: "mori@example.jp", \
      area_of_residence: "北地区", purpose: "楽しんで学びましょう"},

  {name: "煌木次郎", nickname: "煌木先生", email: "moiheszjui_1629816654@tfbnw.net", \
      area_of_residence: "隣町", purpose: ""},

]
members.each do | user |
  timestamp = Time.zone.now + rand(-90..0).days
  user['password'] = 'password'
  user['member'] = true
  user['created_at'] = timestamp
  user['updated_at'] = timestamp
  user['authorized_at'] = timestamp
  user['authorized_by_id'] = User.where(manager: true).sample.id
end
User.create(members)

guests = [
    {name: "煌木花子", nickname: "ハナ", email: "hana@example.jp", \
        area_of_residence: "隣町", purpose: ""},
    {name: "煌木四郎", nickname: "シロー", email: "shiro@example.jp", \
        area_of_residence: "隣町", purpose: ""},
]
guests.each do | user |
  timestamp = Time.zone.now + rand(-70..-50).days
  user['password'] = 'password'
  user['created_at'] = timestamp
  user['updated_at'] = timestamp
end
User.create(guests)
# Facebook Test Users - Facebook上でログイン
# 1. gupyjrgdzs_1629816038@tfbnw.net pw: kiramekipassword
# 2. moiheszjui_1629816654@tfbnw.net pw: kiramekipassword



# follow
30.times do |number|
  member1, member2 = User.where(member: true).sample(2) 
  member1.follow(member2)
end

# note
100.times do |number|
  member = User.where(member: true, manager: [nil, false]).sample
  timestamp = Time.zone.now + (-100 + number).days
  member.notes.create(content: "This is #{number.ordinalize} note created by #{member.nickname}", created_at: timestamp, updated_at: timestamp )
end
# announce
10.times do |number|
  manager = User.where(manager: true).sample
  timestamp = Time.zone.now + (-10 + number).days
  manager.notes.create(content: "これは #{manager.nickname}さんによる #{number} 番目のアナウンスです。", announce: true, created_at: timestamp, updated_at: timestamp)
end

# like
400.times do |number|
  member = User.where(member: true).sample
  member.like(Note.all.sample)
end

# favorite
80.times do |number|
  member = User.where(member: true).sample
  member.favorite(Note.where(announce: true).sample)
end

# lessons
next_mon = Time.zone.now.next_week(:monday) + 18.hours
next_wed = Time.zone.now.next_week(:wednesday) + 19.hours
next_thu = Time.zone.now.next_week(:thursday) + (18.5).hours
next_sat = Time.zone.now.next_week(:saturday) + 14.hours
(-4..2).each do |number|
  mon.lessons.create(name: "マンデー会",   remarks: "いつもどおりです。持ち物は鉛筆とノートです。",\
    started_at: next_mon + (number*7).days, ended_at: next_mon + (number*7).days + 2.hours)
  wed.lessons.create(name: "水曜教室",     remarks: "",\
    started_at: next_wed + (number*7).days, ended_at: next_wed + (number*7).days + 2.hours)
  thu.lessons.create(name: "日本語クラブ", remarks: "",\
    started_at: next_thu + (number*7).days, ended_at: next_thu + (number*7).days + 2.hours)
  sat.lessons.create(name: "Satties",      remarks: "",\
    started_at: next_sat + (number*7).days, ended_at: next_sat + (number*7).days + 2.hours)
end


# attendance
100.times do |number|
  member = User.where(member: true, manager: [nil, false]).sample
  member.attend(Lesson.all.sample)
end

# additional users
20.times do | num |
  timestamp = Time.zone.now + rand(-70..-50).days
  User.create({
    name: "Charlie Brown #{num.ordinalize}",
    nickname: "#{num.ordinalize} Brown",
    email: "charlie#{num}@example.com",
    area_of_residence: "charlie's",
    purpose: "#{num.ordinalize}",
    password: "password",
    member: true,
    created_at: timestamp,
    updated_at: timestamp,
    authorized_at: timestamp,
    authorized_by_id: User.find_by(manager: true).id,
  })
end