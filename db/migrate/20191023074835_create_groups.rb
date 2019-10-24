class CreateGroups < ActiveRecord::Migration[6.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.integer :visibility
      t.integer :unique_group_id
      t.integer :owner_id

      t.timestamps
    end
    add_index :groups, :owner_id
  end
end
