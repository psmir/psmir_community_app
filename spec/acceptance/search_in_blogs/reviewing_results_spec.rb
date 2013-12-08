require 'acceptance/acceptance_helper.rb'

feature "Reviewing results", %q{
  As a visitor
  I want to review results of search
} do

  background do
    @user = create(:user)
  end

  scenario 'Reviewing the list of articles' do
    20.times { |t| create(:article, title: "title#{t}", user: @user) }

    visit root_path

    #  I should see the list of articles with 10 items per page,
    # ordered from new to old
    page.should have_content('title15') # the list is ordered by newest
    page.should_not have_content('title5')

    click_link '2'
    page.should have_content('title5')
    page.should_not have_content('title15')
  end

  scenario 'Reviewing a teaser' do
    article = create(:article,
      title: 'Some title',
      content: Faker::Lorem.paragraphs(3).join(" "),
      user: @user,
      tag_list: 'some tag'
    )

    visit root_path
    page.should have_content 'Some title'
    page.should have_content 'less than a minute ago'

    # I should see the snippet of 100 words followed by ...
    page.should have_content snippet(article.content, 100, '...')
    page.should have_content 'some tag'
    click_link 'Some title'
    current_path.should == article_path(article)
  end
end
