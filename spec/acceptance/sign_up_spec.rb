require 'acceptance/acceptance_helper'

feature 'Signing up' do
  def valid_data
   { :username     => 'bobby',
     :email        => 'bobby@nomail.no',
     :password     => 'password',
     :confirmation => 'password',
     :name         => 'Bob' }
  end

  scenario 'Signig up with confirmation' do
    visit new_user_registration_path
    submit_sign_up_form(valid_data)
    
    page.should have_content 'You have signed up successfully.'
    email = ActionMailer::Base.deliveries.last
    email.to.first.should == 'bobby@nomail.no'
    email.subject.should == 'Confirmation instructions'
    email.body.to_s =~ /<a href="(.*)">Confirm my account<\/a>/
    # visit confirmation url
    visit $1
    page.should have_content 'Your account was successfully confirmed.'
  end

  scenario 'Signing up with empty form' do
    visit new_user_registration_path
    submit_sign_up_form({})
    page.should have_content "Username can't be blank"
    page.should have_content "Email can't be blank"
    page.should have_content "Password can't be blank"
    page.should have_content "Profile name can't be blank"
  end

  scenario 'Signig up with too long username and real name' do
    visit new_user_registration_path
    submit_sign_up_form(valid_data.merge(:username => 'a'*51, :name => 'a'*51))
    page.should have_content 'Username is too long'
    page.should have_content 'Profile name is too long' 
  end

  scenario 'Signing up with invalid email' do
    visit new_user_registration_path
    submit_sign_up_form(valid_data.merge(:email => 'invalid'))
    page.should have_content 'Email is invalid'
  end
end
