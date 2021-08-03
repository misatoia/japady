# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)



=begin
    User.create(name: "Takano", nickname: "sumret", email: "sumret+2@gmail.com", \
    password: "1234", area_of_residence: "my town", purpose: "love studies")

(1..10).each do |number|

    john = User.create(name: "Mr John Lemon#{number}", nickname:"Lemon#{number}", email:"john#{number}@lemon.com", \
    password:"1234", area_of_residence: "Lemon town", purpose: "Learn with Lemon", authorized_by_id:)
    
    johnsnote = john.notes.build(content: "i love lemon. #{number}")

    smith = User.create(name: "Mr Smith Strawberry#{number}", nickname:"Strawberry#{number}", email:"smith#{number}@strawberry.com", \
    password:"1234", area_of_residence: "Strawberry village", purpose: "Learn with Strawberry")

    smithsnote = smith.notes.build(content: "i love Strawberry. #{number}")

    owen = User.create(name: "Mr Owen Vinegar#{number}", nickname:"vinegar#{number}", email:"owen#{number}@vinegar.com", \
    password:"1234", area_of_residence: "Vinegar avenue", purpose: "Learn with Vinegar")

    owensnote = owen.notes.build(content: "i love vinegars. #{number}")

    john.like(owensnote)
    john.like(smithsnote)
    smith.favorite(owensnote)

    john.follow(owen)
    owen.follow(smith)

end

(1..5).each do |number|

    supporter = User.create(name: "Mr Z#{number}", nickname:"sup#{number}", email:"sup#{number}@zzz.com", \
    password:"1234", manager: true)

    announce = supporter.notes.build(content: "this is announcement #{number}", announce: true)
    notannounce = supporter.notes.build(content: "this is not announcement #{number}")
    
    lesson1 = supporter.lessons.build(name: "#{supporter.name}'s lesson", started_at: "2021-05-06 18:00", ended_at: "2021-05-06 19:00")
    lesson2 = supporter.lessons.build(name: "#{supporter.name}'s lesson", started_at: "2021-05-13 18:00", ended_at: "2021-05-13 19:00")
    lesson3 = supporter.lessons.build(name: "#{supporter.name}'s lesson", started_at: "2021-05-20 18:00", ended_at: "2021-05-20 19:00")
    lesson4 = supporter.lessons.build(name: "#{supporter.name}'s lesson", started_at: "2021-05-27 18:00", ended_at: "2021-05-27 19:00")

end

=end
