require 'acceptance/acceptance_helper'

feature 'Signing in and Signing out' do
  background do
   @user = create(:user)
  end

  scenario 'Successful signing in and signing out' do
    log_in @user
    page.should have_content 'Sign out'
    click_link 'Sign out'
    page.should have_content 'Sign in'
  end

  scenario 'Unsuccessful signing in' do
    @user.password = 'wrong password'
    log_in @user
    page.should have_content 'Invalid username or password'
  end
end
