class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :trackable, :validatable, :confirmable

  attr_accessible :username, :email, :password, :password_confirmation,
   :remember_me, :profile_attributes

  has_many :articles
  has_one :profile, dependent: :destroy
  has_many :blogger_readers, dependent: :destroy, foreign_key: 'reader_id'
  has_many :bloggers, through: :blogger_readers, source: :blogger
  has_many :incoming_messages, class_name: 'Message', foreign_key: 'recipient_id'

  accepts_nested_attributes_for :profile

  validates_presence_of :username
  validates_length_of :username, maximum: 30
  validates_uniqueness_of :username

  scope :newest_incoming_messages, -> { incoming_messages.by_newest }


  def follow(blogger)
    self.bloggers << blogger
  end

  def unfollow(blogger)
    self.bloggers.delete blogger
  end


end
