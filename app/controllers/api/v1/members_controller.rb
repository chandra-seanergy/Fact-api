class Api::V1::MembersController < ApplicationController
  before_action :authenticate_request!
  before_action :find_group
  before_action :validate_member, only: [:create]
  before_action :group_member, only: [:destroy]

  # Display list of all members in the group 
  def member_list
    group_members = @group.users.includes(:group_members).map{|x| x.attributes.merge(avatar: x.avatar.url, role: x.group_members.member_type, created_at: x.group_members.created_at, expiration_date: x.group_members.expiration_date])}
    render json: {status: 200, message: "member list fetched successfully.", owner: @group.owner.attributes.merge(avatar: @group.owner.avatar.url), members: group_members}
  end

  # Add Member to Group
  def create
    member = GroupMember.new(memeber_params)
    if member.save
      render json: {status: 201, message: "Member added successfully.",  member: member}
    else
      render json: {status: 500, message: member.errors.full_messages}
    end
  end

  # Remove Member from Group
  def destroy
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
  def memeber_params
    params.require(:group_member).permit(:group_id, :user_id, :member_type, :expiration_date)
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
