# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

UsersCount = 6
admin = User.create(
  :username => 'admin', 
  :email => 'admin@nomail.no', 
  :password => 'password', 
  :password_confirmation => 'password')

admin.admin = true
admin.save
admin.confirm!

admin_profile = Profile.create(
  :user_id   => admin.id, 
  :name      => 'Admin', 
  :gender    => 'male', 
  :birthday  => '12.10.1990',
  :info      => Forgery::LoremIpsum.text(:sentences, 5 , :random => 5)
)

admin_profile.interest_list = Forgery::LoremIpsum.words(3, :random => true).split(' ').join(', ')
admin_profile.save



UsersCount.times do
  user = User.create!(
    :username => Forgery::Internet.user_name, 
    :email => Forgery(:internet).email_address, 
    :password => 'password', 
    :password_confirmation => 'password')

  user.confirm!

  user.profile = Profile.create(
    :name => Forgery::Name.full_name, 
    :gender => Forgery::Personal.gender.downcase, 
    :birthday => Forgery::Date.date(
      :past => true, 
      :min_delta => 7000,
      :max_delta => 10000
    ),
    :info => Forgery::LoremIpsum.text(:sentences, 5 , :random => 5)
  )

  user.profile.interest_list = Forgery::LoremIpsum.words(3, :random => true).split(' ').join(', ')
  user.profile.save   
end

users = User.find(:all)

5.times do
  users.each do |user|
    article = Article.create(
     :title => Forgery::LoremIpsum.title(:random => 5),
     :content => Forgery::LoremIpsum.text(:sentences, 30, :random => 5) 
    )
    
    article.tag_list = Forgery::LoremIpsum.words(3, :random => true).split(' ').join(', ')
    user.articles << article
  end
end

# add up to 4 favorite bloggers
users.each do |user|
  6.times do
    index = rand UsersCount - 1 
    user.bloggers << users[index] unless user.id == users[index].id || user.bloggers.include?(users[index])
  end
end


