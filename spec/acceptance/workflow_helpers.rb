module WorkflowHelpers
  def log_in(user)
    visit new_user_session_path
    fill_in 'Username', :with => user.username
    fill_in 'Password', :with => user.password
    click_button 'Sign in'
  end

  def log_out
    visit destroy_user_session_path
  end

  def page_should_have(data)
    data.each {|item| page.should have_content item }
  end

  def snippet(text, wordcount, omission)
    text.split[0..(wordcount-1)].join(" ") + (text.split.size > wordcount ? " " + omission : "")
  end

  def submit_article_creation_form(data)
    fill_in 'Title', :with => data[:title]
    fill_in 'Content', :with => data[:content]
    fill_in 'Tags', :with => data[:tag_list]
    click_button 'Create'
  end


  def submit_article_edition_form(data)
    fill_in 'Title', :with => data[:title] if data[:title]
    fill_in 'Content', :with => data[:content] if data[:content]
    fill_in 'Tags', :with => data[:tag_list] if data[:tag_list]
    click_button 'Update'
  end

  def submit_message_form(data)
    fill_in 'To', :with => data[:recipient]
    fill_in 'Title', :with => data[:title]
    fill_in 'Message', :with => data[:message]
    click_button 'Send'
  end


  def submit_profile_form(data = {})
    if data[:avatar]
      attach_file('Avatar', Rails.root.join("spec/support/files/#{data[:avatar]}"))
    end
    fill_in 'Name', :with => data[:name]
    choose data[:gender]
    birthday = data[:birthday]
    select birthday.day.to_s, :from => 'profile_birthday_3i'
    select Date::MONTHNAMES[birthday.month], :from => 'profile_birthday_2i'
    select birthday.year.to_s, :from => 'profile_birthday_1i'
    fill_in 'About me', :with => data[:info]
    fill_in 'Interests', :with => data[:interests]
    click_button 'Profile'
  end

  def submit_sign_up_form(data)
    fill_in 'Username', :with => data[:username]
    fill_in 'Email', :with => data[:email]
    fill_in 'Password', :with => data[:password]
    fill_in 'Password confirmation', :with => data[:confirmation]
    fill_in 'Name', :with => data[:name]
    click_button 'Sign up'
  end
end

RSpec.configure do |config|
  config.include WorkflowHelpers
end

