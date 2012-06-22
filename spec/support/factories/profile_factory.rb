Factory.define :profile do |profile|
  profile.name 'Real name'
  profile.gender 'male'
  profile.birthday Date.civil(1990, 03, 15)
  profile.info 'Some information'
  profile.interest_list 'interest1, interest2'
end
