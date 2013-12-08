require 'acceptance/acceptance_helper'

feature "Editing an article", %q{
  As a logged in user
  I want to be able to edit my articles
} do

  background do

    @user = create(:user)
    log_in @user

    @article = create(
      :article,
      title: 'Some title',
      content: 'Some content',
      tag_list: 'first tag, second tag',
      user: @user
    )

    visit edit_article_path(@article)
  end

  scenario 'Editing a blog post' do

    submit_article_edition_form(
      title: 'New title',
      content: 'New content',
      tag_list: 'first tag, third tag'
    )

    current_path.should == article_path(@article)
    page_should_have [
      'The article has been updated',
      'New title',
      'New content',
      'first tag',
      'third tag']

    page.should_not have_content 'second tag'
  end

  scenario 'Editing a blog post with empty title' do
    submit_article_edition_form(attributes_for(:article, title: ''))
    page.should have_content 'The article has not been updated'
    page.should have_content "Title can't be blank"
  end

  scenario 'Editing a blog post with empty content' do
    submit_article_edition_form(attributes_for(:article, content: ''))
    page.should have_content 'The article has not been updated'
    page.should have_content "Content can't be blank"
  end
end
