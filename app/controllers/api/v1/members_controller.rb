class Api::V1::MembersController < ApplicationController
  before_action :authenticate_request!
  before_action :find_group
  before_action :validate_member, only: [:create]
  before_action :group_member, only: [:destroy]

  def member_list
    group_members = @group.users.map{|x| x.attributes.merge(avatar: x.avatar.url)}
    render json: {status: 200, message: "member list fetched successfully.", owner: @group.owner.attributes.merge(avatar: @group.owner.avatar.url), members: group_members}
  end

  def create
    member = GroupMember.new(memeber_params)
    if member.save
      render json: {status: 201, message: "Member added successfully.",  member: member}
    else
      render json: {status: 500, message: member.errors.full_messages}
    end
  end

  def destroy
    if @group_member.destroy
      render json: {status: 200, message: "member removed successfully."}
    else
      render json: {status: 500, message: member.errors.full_messages }
    end
  end

  private
  def find_group
    @group = Group.find_by(id: params[:group_member][:group_id])
    render json: {status: 500, message: "No record found."} unless @group
  end

  def memeber_params
    params.require(:group_member).permit(:group_id, :user_id, :member_type, :expiration_date)
  end

  def validate_member
    @group_member = GroupMember.find_by(group_id: @group.id, user_id: params[:group_member][:user_id])
    render json: {status: 500, message: "member already added."} if @group_member
  end

  def group_member
    @group_member = GroupMember.find_by(group_id: @group.id, user_id: params[:group_member][:user_id])
    render json: {status: 500, message: "member already removed."} unless @group_member
  end
end
