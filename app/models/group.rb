class Group < ApplicationRecord
  enum visibility: { is_private: 0, is_internal: 1, is_public: 2 }
  mount_uploader :avatar, AvatarUploader

  # callbacks
  before_create :generate_group_id

  #validations
  validates :unique_group_id, uniqueness: true
  validates_presence_of :name, :description , :visibility, on: :create

  #associations
  belongs_to :owner, class_name:"User", foreign_key: :owner_id
  has_many :group_members, dependent: :destroy
  has_many :users, through: :group_members

  #scopes
  scope :owned_groups, -> (user) { where(owner:user) }
  scope :public_groups, ->  { where(visibility: Group.visibilities[:is_public]) }
  scope :internal_groups, ->  { where(visibility: Group.visibilities[:is_internal]) }

  def generate_group_id
  	begin
  	  self.unique_group_id = rand(10000000)
  	end until(Group.find_by(unique_group_id: unique_group_id).nil?)
  end
end
