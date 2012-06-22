class CreateBloggerReaders < ActiveRecord::Migration
  def change
    create_table :blogger_readers do |t|
      t.integer :blogger_id
      t.integer :reader_id

      t.timestamps
    end
    
    add_index :blogger_readers, :blogger_id
    add_index :blogger_readers, :reader_id
  end
end
