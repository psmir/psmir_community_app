require 'acceptance/acceptance_helper'
feature 'Search in blogs page controls visibility spec' do
  let(:user){ create_user! }

  scenario 'unsigned in user should not see "in selected blogs" checkbox' do
    visit root_path
    page.should_not have_css "div[id=\"in_selected_blogs\"]"
  end

  scenario 'signed in user should see "in selected blogs" checkbox' do
    log_in user
    visit root_path
    page.should have_css "div[id=\"in_selected_blogs\"]"
  end
  
end
