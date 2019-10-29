class Api::V1::GroupListingController < ApplicationController
  before_action :authenticate_request!

  # Fetch list of all groups where the visibility is public
  def public_groups
    groups = Group.public_groups
    render json: {status: 200, message: "Group list feched successfully.", groups: groups.map{|x|
       x.attributes.merge(avatar: x.avatar.url, member_count: x.group_members.length)}}
  end

  # Fetch list of all groups where the visibility is internal
  def internal_groups
    groups = Group.internal_groups
    render json: {status: 200, message: "Group list feched successfully.", groups: groups.map{|x|
       x.attributes.merge(avatar: x.avatar.url, member_count: x.group_members.length)}}
  end

  # API to accept parameters in object-attribute format and return list of Users
  def user_list
    users = User.search_users(params[:user][:credential])
    render json: {status: 200, message: "member list fecthed successfully.", members: users.map{|x|
      x.attributes.merge(avatar: x.avatar.url)}}
  end

  # API to accept parameters without object-attribute format and return list of Users
  def user_list_simple
    users = User.search_users(params[:credential])
    render json: {status: 200, message: "member list fecthed successfully.", members: users.map{|x|
      x.attributes.merge(avatar: x.avatar.url)}}
  end

  # API To fetch all groups where the user is owner or is a member of
  def your_groups
    all_groups = @current_user.your_groups
    render json: {status: 200, message: "Group list feched successfully.", groups: all_groups.map{|x|
       x.attributes.merge(avatar: x.avatar.url, member_count: x.group_members.length)}}
  end
end
