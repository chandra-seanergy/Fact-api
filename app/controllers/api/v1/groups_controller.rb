class Api::V1::GroupsController < ApplicationController
  before_action :authenticate_request!
  before_action :find_group, only: [:show, :destroy]

  def create
    group = Group.new(group_params)
    group.owner_id = @current_user.id
    group.avatar = params[:group][:avatar] if !params[:group][:avatar].nil? and File.exist?(params[:group][:avatar])
    if group.save
      render json: {status: 200, message: "Group created successfully.", group: group}
    else
      render json:{status: 500, message: group.errors.full_messages}
    end
  end

  def show
    render json: {status: 200, group: @group}
  end

  def destroy
    if @group.destroy
      render json: {status: 200, message: "Group deleted successfully."}
    else
      render json: {status: 500, message: @group.errors.full_messages}
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :description, :visibility)
  end

  def find_group
    @group = Group.find_by(id: params[:id])
    render json: {status: 500, message: "No record found."} unless @group
  end
end
