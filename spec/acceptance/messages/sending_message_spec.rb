require 'acceptance/acceptance_helper'

feature "Sending a message" do

  def valid_attributes
    attributes_for(:message).merge(recipient: @recipient.username)
  end

  background do
    @sender = create(:user)
    @recipient = create(:user)
    log_in @sender
    visit messages_path
    click_link "New message"
  end


  scenario 'Sending a message' do
    submit_message_form valid_attributes
    page.should have_content 'The message has been sent'
  end

  scenario 'Sending with wrong recipient' do
    submit_message_form(valid_attributes.merge(recipient: 'wrong'))
    page.should have_content 'The message has not been sent'
    page.should have_content 'Wrong recipient'
  end

  scenario 'Sending without content' do
    submit_message_form  valid_attributes.merge(message: '')
    page.should have_content 'The message has not been sent'
    page.should have_content "Message can't be blank"
  end
end
