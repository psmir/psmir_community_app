class AddAvatarFieldsToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :avatar_file,        :binary
    add_column :profiles, :avatar_medium_file, :binary
    add_column :profiles, :avatar_thumb_file,  :binary
  end
end
