class Article < ActiveRecord::Base
  belongs_to :user
  validates :title, :content, :presence => true
  attr_accessible :title, :content
  acts_as_taggable
  acts_as_indexed :fields => [:title, :content]
  acts_as_commentable


  scope :default_list, -> { with_users_and_profiles.with_tags.by_newest }
  scope :in_blogs_selected_by, ->(user) { where("user_id IN
   (SELECT blogger_id FROM blogger_readers WHERE reader_id =#{user.id})") }
  scope :by_newest, order('created_at DESC')
  scope :with_tags, includes(:tags)
  scope :with_users_and_profiles, includes(:user => :profile)

  delegate :username, :profile_name, to: :user, prefix: true

  def threaded_comments
    self.comment_threads.order('lft')
  end

end
