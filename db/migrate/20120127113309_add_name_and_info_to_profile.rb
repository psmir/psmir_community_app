class AddNameAndInfoToProfile < ActiveRecord::Migration
  def change
    add_column :profiles, :name, :string
    add_column :profiles, :info, :text
  end
end
