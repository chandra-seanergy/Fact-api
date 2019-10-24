class Group < ApplicationRecord
  before_create :generate_group_id

  validates :unique_group_id, uniqueness: true
  enum visibility: { is_private: 0, is_internal: 1, is_public: 2 }
  validates_presence_of :name, :description , :visibility, on: :create

  def generate_group_id
	begin
		self.unique_group_id = rand(10000000)
	end until(Group.find_by(unique_group_id: unique_group_id).nil?)
  end
end
