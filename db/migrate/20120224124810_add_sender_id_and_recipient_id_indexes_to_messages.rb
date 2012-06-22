class AddSenderIdAndRecipientIdIndexesToMessages < ActiveRecord::Migration
  def change
    add_index :messages, :sender_id
    add_index :messages, :recipient_id
  end
end
