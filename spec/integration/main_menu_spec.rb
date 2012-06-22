require 'acceptance/acceptance_helper'

feature 'Main menu items visibility' do 
  context 'Plain visitor' do
    before do
      visit root_path
    end

    scenario 'Should be visible: Home, Search in blogs, Sign in, Sign up' do
      within("#main_menu") do
        all('a').map{ |a| a[:href] }.should == [ root_path, 
          new_user_session_path, new_user_registration_path, about_path ] 
      end
    end
  end
  
  context 'Logged in user' do
    before do
      @user = create_user!
      log_in @user
      visit root_path
    end
    
    scenario 'Should be visible: Home, Profile, My blog, Messages, Sign out' do
      within("#main_menu") do
        all('a').map{ |a| a[:href] }.should == [ root_path, profile_path(@user.profile), 
          user_articles_path(@user), messages_path, destroy_user_session_path, about_path ] 
      end
    end
  end

  context 'Admin' do
    before do
      @admin = create_user!(:admin => true)
      log_in @admin
      visit root_path
    end
    
    scenario 'Should be visible: Home, Profile, My blog, Messages, Admin, Sign out' do
      within("#main_menu") do
        all('a').map{ |a| a[:href] }.should == [ root_path, profile_path(@admin.profile), 
         user_articles_path(@admin),  messages_path, rails_admin_path, destroy_user_session_path, about_path ] 
      end
    end
  end 
end
