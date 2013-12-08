require 'spec_helper'

describe Message do

  describe 'validation' do
    it { should validate_presence_of :sender_id }
    it { should validate_presence_of(:recipient_id).with_message('Wrong recipient') }
    it { should validate_presence_of(:message) }
  end

  describe 'mass assignment protection' do
    it { should_not allow_mass_assignment_of(:sender_id) }
    it { should_not allow_mass_assignment_of(:recipient_id) }
  end

  describe 'virtual attribute #recipient_username=' do
    it 'assigns recipient by received username' do
      user = create(:user)
      message = Message.new
      message.recipient_username = user.username
      message.recipient.should == user
    end
  end

  describe 'virtual attribute #recipient_username' do
    it 'returns recipient username if message has a recipient' do
      user = create(:user)
      message = Message.new
      message.recipient = user
      message.recipient_username.should == user.username
    end

    it 'returns nil if message does not have a recipient' do
      message = Message.new
      message.recipient_username.should == nil
    end
  end
end
