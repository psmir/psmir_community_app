class Article < ActiveRecord::Base
  belongs_to :user
  validates :title, :content, :presence => true
  attr_accessible :title, :content
  acts_as_taggable
  acts_as_indexed :fields => [:title, :content]
  acts_as_commentable


  scope :blogger_articles, lambda { |user_id| where(user_id: user_id).includes(:tags).order('created_at desc') }
  scope :default_list, includes(:tags, { :user => :profile }).order('created_at desc')
  scope :search_by_query, lambda { |query| with_query(query).includes(:tags, { :user => :profile }) }
  scope :search_by_tag, lambda { |tag| tagged_with(tag).includes(:tags,
    { :user => :profile }).order('created_at desc') }
  scope :in_blogs_selected_by,
    lambda { |user| where("user_id in (select blogger_id from blogger_readers where reader_id =#{user.id})") }



  def threaded_comments
    self.comment_threads.order('lft')
  end

end
