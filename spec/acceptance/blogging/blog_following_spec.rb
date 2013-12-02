require 'acceptance/acceptance_helper'

feature "Blog following", %q{
  In order to receive interesting information rapidly
  As a user
  I want to subscribe/unsubscribe to blogs
} do

   background do
    @bob = create_user!
    log_in(@bob)

    @tom = create_user!
    @tom.profile.name = 'Tom'
    @tom.profile.save
  end

  scenario 'Subscribing to the blog of another user' do
    visit user_articles_path(@tom)
    click_button 'Follow'
    visit user_profile_path(@bob)

    within("#following") do
      page.should have_content 'Tom'
    end

  end

  scenario 'Unsubscribing to the blog of another user' do
    @bob.bloggers << @tom
    visit user_articles_path(@tom)
    click_button 'Unfollow'
    visit profile_path(@bob.profile)

    within("#following") do
      page.should_not have_content 'Tom'
    end
  end
end
