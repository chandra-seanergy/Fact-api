class Api::V1::GroupsController < ApplicationController
  before_action :authenticate_request!
  before_action :find_group, only: [:show, :destroy, :update]

  # API to create groups
  def create
    group, group_avatar = Group.new(group_params), params[:group][:avatar]
    group.owner_id = @current_user.id
    group.avatar = group_avatar if !group_avatar.nil? and File.exist?(group_avatar) #Add Avatar attribute only if valid file exists in params
    if group.save
      render json: {status: 200, message: "Group created successfully.", group: group}
    else
      render json:{status: 500, message: group.errors.full_messages}
    end
  end

  # Display group details
  def show
    render json: {status: 200, group: @group}
  end

  # Delete group from database
  def destroy
    if @group.destroy
      render json: {status: 200, message: "Group deleted successfully."}
    else
      render json: {status: 500, message: @group.errors.full_messages}
    end
  end

  # Update Group Attributes
  def update
    group_avatar = params[:group][:avatar]
    @group.avatar = group_avatar if !group_avatar.nil? and File.exist?(group_avatar)
    if @group.update(group_params)
      render json: {status: 200, message: "Group updated successfully.", avatar: @group.avatar.url}
    else
      render json:{status: 500, message: @group.errors.full_messages}
    end
  end

  private
  # Allow only Strong parameters to be passed to model
  def group_params
    params.require(:group).permit(:name, :description, :visibility)
  end

  # Find groups on the basis of id recieved in parameter
  def find_group
    @group = Group.find_by(id: params[:id])
    render json: {status: 500, message: "No record found."} unless @group
  end
end
