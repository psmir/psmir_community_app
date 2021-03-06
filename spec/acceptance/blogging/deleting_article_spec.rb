require 'acceptance/acceptance_helper'

feature "Deleting an article", %q{
  In order to delete a useless article
  As a logged in user
  I want to make it disappear
} do

  background do
    @user = create(:user)
    log_in(@user)
    create(
      :article,
      title: 'Some title',
      content: 'Some content',
      user: @user
    )

    visit user_articles_path(@user)
  end

  scenario 'Deleting a blog post' do
    click_link 'Some title'
    click_link 'Delete'
    current_path.should == user_articles_path(@user)
    page.should have_content 'The article has been deleted'
    page.should_not have_content 'Some title'
  end
end
