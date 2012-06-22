class AddLevelToComments < ActiveRecord::Migration
  def change
    add_column :comments, :level, :integer, :default => 0
  end
end
