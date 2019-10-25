class GroupMember < ApplicationRecord
  belongs_to :user
  belongs_to :group
  enum member_type: { guest: 0, reporter: 1, developer: 2,maintainer: 3, owner: 4  }
  #validations
  validates_presence_of :user_id, :group_id , on: :create

end
