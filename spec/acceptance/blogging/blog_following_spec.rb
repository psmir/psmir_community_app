require 'acceptance/acceptance_helper'

feature "Blog following", %q{
  In order to receive interesting information rapidly
  As a user
  I want to subscribe/unsubscribe to blogs
} do

   background do
    @user = create(:user)
    log_in @user
    @blogger = create(:user)
  end

  scenario 'Subscribing to the blog of another user' do
    visit user_articles_path(@blogger)
    click_button 'Follow'
    visit profile_path

    within("#following") do
      page.should have_content @blogger.profile_name
    end

  end

  scenario 'Unsubscribing to the blog of another user' do
    @user.bloggers << @blogger
    visit user_articles_path(@blogger)
    click_button 'Unfollow'
    visit profile_path

    within("#following") do
      page.should_not have_content @blogger.profile_name
    end
  end
end
