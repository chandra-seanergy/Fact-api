class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable
  has_one_time_password
  enum otp_module: { disabled: 0, enabled: 1 }, _prefix: true
  mount_uploader :avatar, AvatarUploader
  attr_accessor :otp_code_token

  # validations

  validates_presence_of :name, :username , on: :create
  validates :username, uniqueness: true
  validates_uniqueness_of :public_email, :commit_email, :unique_user_id , allow_blank: true, allow_nil: true

  #callbacks

  before_create :generate_user_id

  #associations

  has_many :owned_groups, class_name:'Group', foreign_key: :owner_id

  def generate_password_token!
   self.reset_password_token = generate_token
   self.reset_password_sent_at = Time.now.utc
   save!
  end

  def password_token_valid?
   (self.reset_password_sent_at + 4.hours) > Time.now.utc
  end

  def reset_password!(password)
   self.reset_password_token = nil
   self.password = password
   save!
  end

  def generate_user_id
    begin
      self.unique_user_id = rand(10000000)
    end until(User.find_by(unique_user_id: unique_user_id).nil?)
  end
end
