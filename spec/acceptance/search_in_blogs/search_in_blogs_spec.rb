require 'acceptance/acceptance_helper.rb'

feature "Search in blogs" do

  background do
    @user1 = create_user!
    @user2 = create_user!

    @article1 = FactoryGirl.create(
      :article,
      :title    => 'article1',
      :content  => 'Some content for article1',
      :user  => @user1,
      :tag_list => 'first tag, second tag')

    @article2 = FactoryGirl.create(
      :article,
      :title    => 'article2',
      :content  => 'Some content for article2',
      :user  => @user2,
      :tag_list => 'second tag')

    visit root_path

  end

  scenario 'Search by tag cloud' do
    click_link 'first tag'
    page.should have_content 'article1'
    page.should_not have_content 'article2'
    click_link 'second tag'
    page.should have_content 'article1'
    page.should have_content 'article2'
  end

  scenario 'Full-text search' do
    choose 'by content'
    fill_in 'query', :with => 'Some for article1'
    click_button 'Search'
    page.should have_content 'article1'
    page.should_not have_content 'article2'
  end

  scenario 'Full-text search via ajax', :js => true do
    choose 'by content'
    fill_in 'query', :with => 'Some for article1'
    click_button 'Search'
    page.should have_content 'article1'
    page.should_not have_content 'article2'
  end

  scenario 'Search by tag list' do
    choose 'by tags'

    fill_in 'query', :with => 'first tag, second tag'
    click_button 'Search'
    page.should have_content 'article1'
    page.should_not have_content 'article2'

    fill_in 'query', :with => 'second tag'
    click_button 'Search'
    page.should have_content 'article1'
    page.should have_content 'article2'
  end

  scenario 'Search in selected blogs' do
    some_user = create_user!
    log_in some_user
    some_user.bloggers << @user1
    visit root_path
    page.should have_content 'article1'
    page.should have_content 'article2'
    fill_in 'query', :with => 'Some content'
    check 'in selected blogs'
    click_button 'Search'
    page.should have_content 'article1'
    page.should_not have_content 'article2'
    uncheck 'in selected blogs'
    click_button 'Search'
    page.should have_content 'article1'
    page.should have_content 'article2'
  end
end
