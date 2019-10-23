class AddProfileFeildsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :user_id, :integer
    add_column :users, :public_email, :string
    add_column :users, :commit_email, :string
    add_column :users, :skype, :string
    add_column :users, :linkedin, :string
    add_column :users, :twitter, :string
    add_column :users, :website_url, :string
    add_column :users, :location, :string
    add_column :users, :organization, :string
    add_column :users, :bio, :text
    add_column :users, :private_profile, :boolean, default: false
    add_column :users, :private_contributions, :boolean, default: false
    add_index :users, :user_id,                unique: true
    add_index :users, :public_email,           unique: true
    add_index :users, :commit_email,           unique: true
  end
end
