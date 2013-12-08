require 'acceptance/acceptance_helper'

feature "Commenting an article", %q{
  In order to express my opinion about some article
  As a logged in user
  I want to comment it, review others comments and reply to them
} do

  before(:each) do
    @user = create(:user)
    log_in @user
    @article = create(:article, :title => 'Some title')
  end

  scenario 'Creating a regular comment' do
    visit article_path(@article)
    click_link 'Add comment'
    fill_in 'comment_body', :with => 'Some comment'
    click_button 'Create Comment'

    current_path.should == article_path(@article)
    page.should have_content 'The comment has been created'
    page.should have_content 'Some comment'
  end

  scenario 'Replying to some comment' do
    @comment = Comment.build_from(@article, create(:user).id, 'Some comment')
    @comment.save
    visit article_path(@article)
    click_link 'Reply'
    fill_in 'comment_body', :with => 'Reply to some comment'
    click_button 'Create Comment'
    current_path.should == article_path(@article)
    page.should have_content 'Reply to some comment'
  end

  scenario 'Reviewing the list of comments' do

    @first = Comment.build_from(@article, create(:user).id, 'First')
    @first.save

    @second = Comment.build_from(@article, create(:user).id, 'Second')
    @second.save

    visit article_path(@article)

    within("#comment_#{@first.id}") do
      click_link 'Reply'
    end

    fill_in 'comment_body', :with => 'My reply'
    click_button 'Create Comment'
    # comments should be displayed hierarchically
    page.body.should =~ /First.*My reply.*Second/m
  end

  scenario 'Reviewing some comment' do

    @comment = Comment.build_from(@article, create(:user).id, 'Some comment')
    @comment.save

    visit article_path(@article)

    page.should have_content 'Some comment'
    page.should have_content 'less than a minute ago'
    page.should have_content @comment.user_profile_name
    # avatar
    page.should have_xpath ("//img[@src=\"#{@user.profile_avatar_url(:thumb)}\"]")
    click_link @comment.user_username
    current_path.should == user_profile_path(@comment.user)

  end
end
