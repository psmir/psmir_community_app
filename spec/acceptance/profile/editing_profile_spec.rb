require 'acceptance/acceptance_helper'

feature "Editing a profile", %q{
  In order to have present-day profile
  As a logged in user 
  I want to update it
} do

  background do
    @user = create_user!
    log_in(@user)
    Factory(:profile, :user_id => @user.id)
    visit edit_profile_path(@user.profile)
  end

  scenario 'Editing a profile' do

    submit_profile_form(
      :avatar    => 'avatar2.jpg',
      :name      => 'Lisa',
      :gender    => 'female', 
      :birthday  => Date.civil(1992, 10, 12),
      :info      => 'New information',    
      :interests => 'fitness, music')
     
    current_path.should == profile_path(@user.profile)    
    @user.reload
    page.should have_xpath ("//img[@src=\"#{@user.profile.avatar.url(:original)}\"]")
    page.should have_content 'Lisa'
    page.should have_content 'female'
    page.should have_content '12 October 1992'
    page.should have_content 'New information'
    page.should have_content 'fitness'
    page.should have_content 'music'
  end

  scenario 'Editing the profile without a name' do
    submit_profile_form Factory.attributes_for(:profile, :name => '')
    page.should have_content "Name can't be blank"
  end

  scenario 'Editing the profile with a name more than 50 characters long' do
    submit_profile_form Factory.attributes_for(:profile, :name => 'a'*51)
    page.should have_content "Name is too long"
  end
end
