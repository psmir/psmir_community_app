require 'acceptance/acceptance_helper'

feature "Viewing articles", %q{
  As a user 
  I want to see the list of my articles
} do

  background do 
    @user = create_user! 
    log_in(@user)
  end

  scenario 'Viewing list of articles' do
    20.times do |t|
      Factory(:article, :title => "title#{t}", :user_id => @user.id)
    end
 
    visit user_articles_path(@user) 
   
    page.should have_content('title15') # list is ordered by created_at desc
    page.should_not have_content('title5')
 
    click_link '2'
      
    page.should have_content('title5')
    page.should_not have_content('title15')
  end

  scenario 'Viewing article teaser' do
    article = Factory(:article, 
                      :title => 'Some title', 
                      :content => Forgery::LoremIpsum.text(:sentences, 10,
                                                           :random => 5), 
                      :user_id => @user.id,
                      :tag_list => 'first tag, second tag')
    
    visit user_articles_path(@user)
    
    page.should have_content 'Some title'
    page.should have_content 'Posted less than a minute ago'
    page.should have_content snippet(article.content, 100, '...')
    page.should have_content 'first tag'
    page.should have_content 'second tag'

    click_link 'Some title'
 
    current_path.should == user_article_path(@user, article)
  end

  scenario 'Searching similar articles by tag' do
    article1 = Factory(
      :article, 
      :title => 'Article1', 
      :user_id => @user.id,
      :tag_list => 'some tag')

    another_user = create_user!
    article2 = Factory(
      :article, 
      :title => 'Article2', 
      :user_id => another_user.id,
      :tag_list => 'some tag')
    
    article3 = Factory(
      :article, 
      :title => 'Article3', 
      :user_id => another_user.id)

    visit user_articles_path(@user)
    
    click_link 'some tag'

    current_path.should == tagged_articles_path
    
    page.should have_content 'Article1'
    page.should have_content 'Article2'
    page.should_not have_content 'Article3'
  end
end
