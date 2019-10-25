class CreateGroupMembers < ActiveRecord::Migration[6.0]
  def change
    create_table :group_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.integer :member_type

      t.timestamps
    end
  end
end
