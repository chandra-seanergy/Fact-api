class AddVisitCountToGroupMembers < ActiveRecord::Migration[6.0]
  def change
    add_column :group_members, :visit_count, :integer, default: 0
  end
end
