class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  

  has_many :articles
  has_one :profile, :dependent => :destroy
  accepts_nested_attributes_for :profile
  has_many :blogger_readers, :dependent => :destroy, :foreign_key => 'reader_id' 
  has_many :bloggers, :through => :blogger_readers, :source => :blogger
  has_many :incoming_messages, :class_name => 'Message', :foreign_key => 'recipient_id'


  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :profile_attributes  

  validates_presence_of :username
  validates_length_of :username, :maximum => 30
  validates_uniqueness_of :username 

  after_save :remove_user_from_cache
  after_destroy :remove_user_from_cache

  def self.fetch(id)
    Rails.cache.fetch("user_#{id}") { User.find(id) }
  end

  def follow(blogger)
    self.bloggers << blogger
  end

  def unfollow(blogger)
    self.bloggers.delete blogger
  end

private 
  def remove_user_from_cache
    Rails.cache.delete("user_#{self.id}")
  end
 


end
