class Article < ActiveRecord::Base
  belongs_to :user
  validates :title, :content, :presence => true
  attr_accessible :title, :content
  acts_as_taggable
  acts_as_indexed :fields => [:title, :content]
  acts_as_commentable


  scope :default_list, -> { with_users_and_profiles.with_tags.by_newest }
  scope :search_by_query, lambda { |query| with_query(query).includes(:tags, { :user => :profile }) }
  scope :search_by_tag, lambda { |tag| tagged_with(tag).includes(:tags,
    { :user => :profile }).order('created_at desc') }
  scope :in_blogs_selected_by,
    lambda { |user| where("user_id in (select blogger_id from blogger_readers where reader_id =#{user.id})") }

  scope :by_newest, order('created_at DESC')
  scope :with_tags, includes(:tags)
  scope :with_users_and_profiles, includes(:user => :profile)



  def threaded_comments
    self.comment_threads.order('lft')
  end

end
