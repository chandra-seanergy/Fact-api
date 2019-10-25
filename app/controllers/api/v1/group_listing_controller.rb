class Api::V1::GroupListingController < ApplicationController
  before_action :authenticate_request!

  def index
    groups = Group.public_groups
    render json: {status: 200, message: "Group list feched successfully.", groups: groups.map{|x|
       x.attributes.merge(avatar: x.avatar.url)}}
  end
end
