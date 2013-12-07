class Profile < ActiveRecord::Base
  belongs_to :user
  acts_as_taggable_on :interests

  has_attached_file :avatar,
    :default_url => '/images/noavatar_:style.jpeg',
    :url => '/profile/:id/avatar?style=:style',
    :storage => :database,
    :styles => {
      :original => {:geometry => "300x300>", :column => 'avatar_file'},
      :medium => {:geometry => "120x120>", :column => 'avatar_medium_file'},
      :thumb =>  {:geometry => "32x32>", :column => 'avatar_thumb_file'}
    }

  validates_presence_of :name
  validates_length_of :name, :maximum => 50
  validates_inclusion_of :gender, :in => ['male', 'female']
  validates_inclusion_of :birthday, :in => Date.new(1900, 1, 1)..(Date.today - 16.years)


  def get_avatar_file(style)
    return avatar_thumb_file if style == 'thumb'
    return avatar_medium_file if style == 'medium'
    return avatar_file if style == 'original'
  end

  def avatar_url(*args)
    avatar.url(*args)
  end
end
