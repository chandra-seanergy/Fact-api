class GroupMember < ApplicationRecord
  enum member_type: { guest: 0, reporter: 1, developer: 2, maintainer: 3, owner: 4 }
  #validations
  validates_presence_of :user_id, :group_id , on: :create

  #associations
  belongs_to :user
  belongs_to :group

  def self.bulk_add_hash(member_params)
  	GroupMember.where("group_id=? and user_id in (?)",member_params[:group_id],member_params[:user_id]).destroy_all
  	members = []
    member_params[:user_id].each do |user_id|
    	members<<{group_id: member_params[:group_id], user_id: user_id, member_type: member_params[:member_type].to_i, expiration_date: member_params[:expiration_date]}
    end
    return members
  end
end