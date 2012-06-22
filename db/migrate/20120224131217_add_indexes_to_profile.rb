class AddIndexesToProfile < ActiveRecord::Migration
  def change
    add_index :profiles, :id
    add_index :profiles, :user_id
    add_index :profiles, :name
  end
end
