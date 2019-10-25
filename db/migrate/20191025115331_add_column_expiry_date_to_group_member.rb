class AddColumnExpiryDateToGroupMember < ActiveRecord::Migration[6.0]
  def change
    add_column :group_members, :expiration_date, :date
  end
end
