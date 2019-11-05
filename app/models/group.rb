class Group < ApplicationRecord
  enum visibility: { is_private: 0, is_internal: 1, is_public: 2 }
  mount_uploader :avatar, AvatarUploader

  # callbacks
  before_create :generate_group_id
  after_create :map_owner_to_memberlist

  #validations
  validates :unique_group_id, uniqueness: true
  validates_presence_of :name, :visibility, on: :create

  #associations
  belongs_to :owner, class_name:"User", foreign_key: :owner_id
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  #scopes
  scope :owned_groups, -> (user) { where(owner:user).includes(:group_members) }
  scope :public_groups, ->  { where(visibility: Group.visibilities[:is_public]).includes(:group_members) }
  scope :internal_groups, ->  { where(visibility: Group.visibilities[:is_internal]).includes(:group_members) }

  # Generate Unique Group Id of 7 Digits to be saved before creating a entry
  def generate_group_id
  	begin
  	  self.unique_group_id = rand(10000000)
  	end until(Group.find_by(unique_group_id: unique_group_id).nil?)
  end

  # Map creater as primary_owner of group
  def map_owner_to_memberlist
    GroupMember.create(group: self, user_id: self.owner_id, member_type: 5)
  end

  # Find public groups on the basis of search parameters and sort filters
  def self.find_public_groups(search_params)
    search_params[:name]||=""
    search_params[:sort_by]||="created_at desc"
    Group.public_groups.where("name ILIKE :search", search: "%#{search_params[:name].strip}%").order(search_params[:sort_by])
  end

  # Find internal groups on the basis of search parameters and sort filters
  def self.find_internal_groups(search_params)
    search_params[:name]||=""
    search_params[:sort_by]||="created_at desc"
    Group.internal_groups.where("name ILIKE :search", search: "%#{search_params[:name].strip}%").order(search_params[:sort_by])
  end

  # Search and find members of the group and return a sorted list
  def get_member_list(search_params)
    search_params[:credential]||=""
    search_params[:sort_by]||="name ascending"
    self.users.includes(:group_members)
    .where("name ILIKE :search OR username ILIKE :search OR email ILIKE :search", search: "%#{search_params[:credential].strip}%")
    .order(member_sort_criteria(search_params[:sort_by]))
    .map{|x| x.attributes.merge(avatar: x.avatar.url, role: x.group_members.last.member_type, roleId: x.group_members.last.member_type_before_type_cast, joined_at: x.group_members.last.created_at, expiration_date: x.group_members.last.expiration_date)}
  end

  # Returns the suitable order by clause for the query on the basis of filter applied
  def member_sort_criteria(sort_by)
    case sort_by
    when "last joined"
      "group_members.created_at desc"
    when "name ascending"
      "LOWER(users.name) asc"
    when "name descending"
      "LOWER(users.name) desc"
    when "oldest joined"
      "group_members.created_at asc"
    when "oldest sign-in"
      "users.created_at desc"
    when "recent sign-in"
      "users.created_at asc"
    end
  end
end
