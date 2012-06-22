require 'acceptance/acceptance_helper'

feature 'Article page controls visibility' do
  before do
    @blogger = create_user!(:username => 'bob')
    @article = Factory(:article, :user_id => @blogger.id)
    @user = create_user!
    @comment = Comment.build_from(@article, @user, 'Some comment')
    @comment.save    
  end

  scenario %q{ Visitor should see: link to blog index
               And should not see: eidt article, delete article, add comment, reply links } do

    visit user_article_path(@blogger, @article)
    page.should have_content "bob's blog"
    page.should_not have_css 'a[id="article_edit_link"]'
    page.should_not have_css 'a[id="article_delete_link"]'
    page.should_not have_css 'a[class="reply_to_comment_link"]'
    page.should_not have_content 'Add comment'
  end

  scenario %q{ User should see: blog index, add comment, reply to comment links
               And should not see: eidt article, delete article links } do
    log_in @user
    visit user_article_path(@blogger, @article)
    page.should have_content "bob's blog"
    page.should have_css 'a[class="reply_to_comment_link"]'
    page.should_not have_css 'a[id="article_edit_link"]'
    page.should_not have_css 'a[id="article_delete_link"]'
    page.should have_content 'Add comment'
  end


  scenario %q{ Blogger should see: blog index, add comment, reply to comment links,
               edit article, delete article links } do
    log_in @blogger
    visit user_article_path(@blogger, @article)
    page.should have_content "bob's blog"
    page.should have_css 'a[class="reply_to_comment_link"]'
    page.should have_css 'a[id="article_edit_link"]'
    page.should have_css 'a[id="article_delete_link"]'
    page.should have_content 'Add comment'
  end
end
