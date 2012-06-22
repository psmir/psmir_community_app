class AddIdIndexToMessages < ActiveRecord::Migration
  def change
    add_index :messages, :id
  end
end
