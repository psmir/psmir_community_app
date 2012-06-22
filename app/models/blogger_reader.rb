class BloggerReader < ActiveRecord::Base
  attr_accessible :reader_id
  belongs_to :blogger, :class_name => 'User'
  belongs_to :reader, :class_name => 'User' 
end
