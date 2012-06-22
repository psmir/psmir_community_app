class Article < ActiveRecord::Base
  belongs_to :user
  validates :title, :content, :presence => true 
  attr_accessible :title, :content
  acts_as_taggable
  acts_as_indexed :fields => [:title, :content]
  acts_as_commentable


  after_save  :update_user_articles_base_key, :update_articles_base_key, :clear_article_cache
  after_destroy :update_user_articles_base_key, :update_articles_base_key, :clear_article_cache

  scope :blogger_articles, lambda { |user_id| where(user_id: user_id).includes(:tags).order('created_at desc') }
  scope :default_list, includes(:tags, { :user => :profile }).order('created_at desc')
  scope :search_by_query, lambda { |query| with_query(query).includes(:tags, { :user => :profile }) }
  scope :search_by_tag, lambda { |tag| tagged_with(tag).includes(:tags, 
    { :user => :profile }).order('created_at desc') } 
  scope :in_blogs_selected_by, 
    lambda { |user| where("user_id in (select blogger_id from blogger_readers where reader_id =#{user.id})") }

  

  def self.fetch(id)
    Rails.cache.fetch("article_#{id}") { Article.find(id) }
  end

  def self.user_articles_base_key(user_id)
    Rails.cache.fetch("user-articles-base-key-#{user_id}") { 1 }
  end
 
  def self.articles_base_key
    Rails.cache.fetch("articles-base-key") { 1 } 
  end

  def threaded_comments
    self.comment_threads.order('lft')
  end

private

  
  
  def clear_article_cache
    Rails.cache.delete("article_#{self.id}")
  end

  def update_user_articles_base_key
    value = Rails.cache.read("user-articles-base-key-#{self.user_id}") || 1
    Rails.cache.write "user-articles-base-key-#{self.user_id}", value + 1
  end

  def update_articles_base_key
    value = Rails.cache.read("articles-base-key") || 1
    Rails.cache.write "articles-base-key", value + 1
  end

  
end
