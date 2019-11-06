class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  has_one_time_password
  enum otp_module: { disabled: 0, enabled: 1 }, _prefix: true
  mount_uploader :avatar, AvatarUploader
  attr_accessor :otp_code_token
  include PgSearch::Model

  # validations

  validates_presence_of :name, :username , on: :create
  validates :username, uniqueness: true
  validates_uniqueness_of :unique_user_id , allow_blank: true, allow_nil: true

  #callbacks

  before_create :generate_user_id

  #associations

  has_many :owned_groups, class_name:'Group', foreign_key: :owner_id, dependent: :destroy
  has_many :group_members, dependent: :destroy
  has_many :groups, through: :group_members

  # Generate password reset token and save that to database
  def generate_password_token!
   self.reset_password_token = generate_token
   self.reset_password_sent_at = Time.now.utc
   save!
  end

  # Validate the expiry of reset token that whether it was sent within past 4 hours or not
  def password_token_valid?
   (self.reset_password_sent_at + 4.hours) > Time.now.utc
  end

  # Reset password and remove password reset link
  def reset_password!(password)
   self.reset_password_token = nil
   self.password = password
   save!
  end

  # Generate Unique User Id of 7 Digits to be saved before creating a entry
  def generate_user_id
    begin
      self.unique_user_id = rand(10000000)
    end until(User.find_by(unique_user_id: unique_user_id).nil?)
  end

  # Search users on the basis of credentials like name, username or email.
  def self.search_users(credential='')
    credentials = "%#{credential}%"
    where("name ILIKE :search OR username ILIKE :search OR email ILIKE :search", search: credentials)
  end

  # Find the list of groups to be populated in your groups section on the basis that user should be the owner of group or a member of group or the group is internal group.
  def your_groups(search_params)
    search_params[:name]||=""
    search_params[:sort_by]||="created_at desc"
    Group.where("groups.id IN (SELECT groups.id FROM groups JOIN group_members on(group_members.group_id=groups.id) where group_members.user_id=:user_id and group_members.expiration_date>now() or group_members.expiration_date is null and groups.name ILIKE :search) OR groups.id IN (SELECT groups.id from groups where owner_id=:user_id and name ILIKE :search) OR groups.id IN (SELECT groups.id from groups where visibility = 1 and name ILIKE :search)", search: "%#{search_params[:name].strip}%", user_id: self.id).order(search_params[:sort_by])
  end

  # Find recently visited groups on the basis of visit count
  def find_frequent_groups
    self.groups.includes(:group_members)
    .where("group_members.visit_count<>0")
    .order("group_members.visit_count desc")
    .limit(5)
  end
end
