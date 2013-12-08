require 'acceptance/acceptance_helper'

feature "Creating an article", %q{
  As a logged in user
  I want to be able to create an article
} do

  background do
    @user = create(:user)
    log_in(@user)
    visit new_article_path
  end

  scenario 'Creating an article' do
    submit_article_creation_form(
      attributes_for(
        :article,
        title: 'Some title',
        content: 'Some content',
        tag_list: 'some tag'
      )
    )

    article = Article.first
    current_path.should == article_path(article)
    page.should have_content 'The article has been created'
    page.should have_content 'Some title'
    page.should have_content 'Some content'
    page.should have_content 'some tag'
  end

  scenario 'Creating an article with invalid attributes' do
    submit_article_creation_form(
      attributes_for(
        :article,
        title: '',
        content: ''
      )
    )

    page.should have_content 'The article has not been created'
    page.should have_content "Title can't be blank"
    page.should have_content "Content can't be blank"
  end

end
