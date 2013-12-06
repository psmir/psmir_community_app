class Message < ActiveRecord::Base
  belongs_to :sender, :class_name => 'User'
  belongs_to :recipient, :class_name => 'User'
  validates_presence_of :recipient_id, :message => 'Wrong recipient'
  validates_presence_of :sender_id
  validates_presence_of :message
  attr_accessible :title, :message, :recipient_username

  scope :by_newest, -> { order('created_at DESC') }

  def recipient_username=(value)
    user = User.find_by_username(value)
    self.recipient_id = user.id if user
  end

  def recipient_username
    self.recipient.username if self.recipient
  end
end
