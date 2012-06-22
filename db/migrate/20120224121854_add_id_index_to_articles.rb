class AddIdIndexToArticles < ActiveRecord::Migration
  def change
    add_index :articles, :id
  end
end
