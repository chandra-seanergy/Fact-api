class Api::V1::GroupListingController < ApplicationController
  before_action :authenticate_request!

  # Fetch list of all groups where the visibility is public
  def public_groups
    groups = Group.find_public_groups(search_params)
    render json: {status: 200, message: "Group list feched successfully.", groups: response_list(groups)}
  end

  # Fetch list of all groups where the visibility is internal
  def internal_groups
    groups = Group.find_internal_groups(search_params)
    render json: {status: 200, message: "Group list feched successfully.", groups: response_list(groups)}
  end

  # API to accept parameters in object-attribute format and return list of Users
  def user_list
    users = User.search_users(params[:user][:credential])
    render json: {status: 200, message: "member list fecthed successfully.", members: response_list(users)}
  end

  # API to accept parameters without object-attribute format and return list of Users
  def user_list_simple
    users = User.search_users(params[:credential])
    render json: {status: 200, message: "member list fecthed successfully.", members: response_list(users)}
  end

  # API To fetch all groups where the user is owner or is a member of
  def your_groups
    all_groups = @current_user.your_groups(search_params)
    render json: {status: 200, message: "Group list feched successfully.", groups: response_list(all_groups)}
  end

  private
  # Allow parameters to be passed to model for search and sort filters
  def search_params
    params.permit(:name, :sort_by)
  end
  # Reduce Code redundancy by creating common method for common response json
  def response_list(list)
    list.map{|x| x.attributes.merge(avatar: x.avatar.url, member_count: x.group_members.length)}
  end
end
