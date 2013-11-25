require 'acceptance/acceptance_helper'

feature "Viewing an article", %q{
  As a user 
  I want to be able to view any of my articles
} do

  background do 
    @user = create_user!
    log_in(@user)
    @article = Factory(
      :article, 
      :title => 'Some title', 
      :content => 'Some content', 
      :user_id => @user.id)
    
  end

  scenario 'Viewing an article' do
    visit user_articles_path(@user)
    click_link 'Some title'
    current_path.should == user_article_path(@user, @article)

    page.should have_content 'Some title'
    page.should have_content 'Some content'
    page.should have_content 'less than a minute ago'
  end
end