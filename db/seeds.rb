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
]
admins.each do | user |
    user['password'] = 'password'
    user['admin'] = true
end
User.create(admins)


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

]
members.each do | user |
    user['password'] = 'password'
    user['member'] = true
    user['authorized_by_id'] = User.find_by(admin: true)
end
User.create(members)

# Facebook Test Users - Facebook上でログイン
# 1. gupyjrgdzs_1629816038@tfbnw.net pw: kiramekipassword
# 2. moiheszjui_1629816654@tfbnw.net pw: kiramekipassword


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
    user['password'] = 'password'
    user['manager'] = true
    user['member'] = true
    user['authorized_by_id'] = User.find_by(admin: true)
end
mon, wed, thu, sat = User.create(managers)


# follow
(1..20).each do |number|
  member1, member2 = User.all.sample(2) 
  member1.follow(member2)
end

# note
(1..60).each do |number|
  member = User.where(manager: [nil, false]).sample
  timestamp = Time.zone.now + rand(-100..0).days
  member.notes.create(content: "This is note #{number.ordinalize} note created by #{member.nickname}", created_at: timestamp, updated_at: timestamp )
end
# announce
(1..10).each do |number|
  manager = User.where(manager: true).sample
  timestamp = Time.zone.now + rand(-100..0).days
  manager.notes.create(content: "これは #{manager.nickname}さんによる #{number} 番目のアナウンスです。", announce: true, created_at: timestamp, updated_at: timestamp)
end

# like
(1..400).each do |number|
  member = User.all.sample
  member.like(Note.all.sample)
end

# favorite
(1..100).each do |number|
  member = User.all.sample
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
(1..80).each do |number|
  member = User.where(manager: [nil, false]).sample
  member.attend(Lesson.all.sample)
end

