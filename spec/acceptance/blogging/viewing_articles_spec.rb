require 'acceptance/acceptance_helper'

feature "Viewing articles", %q{
  As a user
  I want to see the list of my articles
} do

  background do
    @user = create(:user)
    log_in @user
  end

  scenario 'Viewing list of articles' do
    20.times { |t| create(:article, title: "title#{t}", user: @user) }

    visit user_articles_path(@user)

    page.should have_content('title15') # list is ordered by newest
    page.should_not have_content('title5')

    click_link '2'

    page.should have_content('title5')
    page.should_not have_content('title15')
  end

  scenario 'Viewing article teaser' do
    article = create(:article,
      content: Faker::Lorem.paragraphs(5).join(" "),
      user: @user,
      tag_list: 'first tag, second tag')

    visit user_articles_path(@user)
    page_should_have [
      article.title,
      'less than a minute ago',
      snippet(article.content, 100, '...'),
      'first tag',
      'second tag'
    ]

    click_link article.title
    current_path.should == article_path(article)
  end

  scenario 'Searching similar articles by tag' do
    article1 = create(:article, user: @user,  tag_list: 'some tag')

    article2 = create(:article, tag_list: 'some tag')
    article3 = create(:article)

    visit user_articles_path(@user)

    click_link 'some tag'

    current_path.should == articles_path

    page_should_have [ article1.title, article2.title ]
    page.should_not have_content article3.title
  end
end
