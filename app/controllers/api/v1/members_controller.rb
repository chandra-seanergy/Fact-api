class Api::V1::MembersController < ApplicationController
  before_action :authenticate_request!
  before_action :find_group
  before_action :group_member, only: [:delete_member]

  # Display list of all members in the group 
  def member_list
    group_members = @group.get_member_list(member_params)
    render json: {status: 200, message: "member list fetched successfully.", members: group_members}
  end

  # Add Member to Group
  def create
    member = GroupMember.bulk_add_hash(member_params)
    if GroupMember.import!(member)
      render json: {status: 201, message: "Members added successfully.", member: member}
    else
      render json: {status: 500, message: member.errors.full_messages}
    end
  end

  # Remove Member from Group
  def delete_member
    if @group_member.destroy
      render json: {status: 200, message: "member removed successfully."}
    else
      render json: {status: 500, message: member.errors.full_messages }
    end
  end

  private
  # Find group based on group id
  def find_group
    @group = Group.find_by(id: params[:group_member][:group_id])
    render json: {status: 500, message: "No record found."} unless @group
  end

  # Allow only strong parameters to be used for Model Interaction
  def member_params
    params.require(:group_member).permit(:group_id, :member_type, :credential, :sort_by, :expiration_date, :user_id => [])
  end

  # Validate if a member that needs to be added is already a member of group or not
  def validate_member
    @group_member = GroupMember.find_by(group_id: @group.id, user_id: params[:group_member][:user_id])
    render json: {status: 500, message: "member already added."} if @group_member
  end

  # Validate before removing that whether a user is already removed or not
  def group_member
    @group_member = GroupMember.find_by(group_id: @group.id, user_id: params[:group_member][:user_id])
    render json: {status: 500, message: "member already removed."} unless @group_member
  end
end
