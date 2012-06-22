require 'acceptance/acceptance_helper'
feature 'Blog controls visibility ' do
  let(:user){ create_user! }
  let(:blogger){ create_user! }  

  scenario 'Plain visitor should not see: Follow/Unfollow buttons, Add post link' do
    visit user_articles_path(blogger)
    page.should_not have_css 'input[value="Follow"]'
    page.should_not have_css 'input[value="Unfollow"]'
    page.should_not have_css "a[href=\"#{new_article_path}\"]"
  end

  scenario 'User should not see Add post link' do
    log_in user
    visit user_articles_path(blogger)
    page.should_not have_css "a[href=\"#{new_article_path}\"]"
  end
  
  scenario 'Unsubscribed user should see Follow and should not see Unfollow' do
    log_in user
    visit user_articles_path(blogger)
    page.should have_css 'input[value="Follow"]'
    page.should_not have_css 'input[value="Unfollow"]'
  end

  scenario 'Subscribed user should not see Follow and should see Unfollow' do
    user.bloggers << blogger
    log_in user 
    visit user_articles_path(blogger)
    page.should_not have_css 'input[value="Follow"]'
    page.should have_css 'input[value="Unfollow"]'
  end

  scenario %{ Blog owner should see Add post link and should not see 
              Follow/Unfollow buttons } do
    log_in blogger
    visit user_articles_path(blogger)
    page.should have_css "a[href=\"#{new_article_path}\"]"
    page.should_not have_css 'input[value="Follow"]'
    page.should_not have_css 'input[value="Unfollow"]'
  end
end
  
