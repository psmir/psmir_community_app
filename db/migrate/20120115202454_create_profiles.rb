class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.column(:gender, :string)
      t.column(:birthday, :date)
      t.timestamps
    end
  end
end
