require 'acceptance/acceptance_helper'

feature 'Managing the list of messages' do

  background do
    @sender = create_user!(:username => 'tommy')
    @sender.profile.name = 'Tom'
    @sender.save

    @recipient = create_user!(:username => 'bobby')
    @recipient.profile.name = 'Bob'
    @recipient.save

    log_in @recipient
  end
  
  scenario 'Viewing the list of messages' do
    # the list should be paginated with 10 items per page and sorted from new to old
    20.times { Factory(:message, :sender_id => @sender.id, :recipient_id => @recipient.id) }
    visit messages_path
    page.should have_content 'title19'
    page.should_not have_content 'title5'

    click_link '2'
    page.should have_content 'title5'
    page.should_not have_content 'title19'    
  end

  
  context 'there is an incoming message' do
    before do
       @message = Factory(
        :message, 
        :sender_id => @sender.id, 
        :recipient_id => @recipient.id, 
        :title => 'Some title', 
        :message => 'Some message')
     
      visit messages_path
    end

    scenario 'Viewing a teaser' do
     
      # title, sender, time
      page_should_have ['Some title', @sender.username, 'less than a minute']
      # View and Delete buttons
      page.should have_selector('input[value="View"]')
      page.should have_selector('input[value="Delete"]') 
      # sender name should be a link to sender's profile
      page.should have_selector('a', :href => profile_path(@sender.profile), 
        :text => @sender.username) 
      
    end

    scenario 'Viewing a message' do
      click_button 'View'
      # title, sender, message, time
      page_should_have ['Some title', @sender.username,'Some message',
        'less than a minute']

      # sender name should be a link to sender's profile
      page.should have_selector('a', :href => profile_path(@sender.profile), 
        :text => @sender.username) 
      
      # link to incoming messages
      page.should have_selector('a', :href => messages_path) 

    end

    scenario 'Deleting a message from the list' do
      click_button 'Delete'
      current_path.should == messages_path
      page.should_not have_content 'Some title'
    end
  end 
end
