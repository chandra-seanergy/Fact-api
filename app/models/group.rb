class Group < ApplicationRecord
  after_create :generate_group_id

  validates :unique_group_id, uniqueness: true
  enum visibility: { personal: 0, internal: 1, external: 2 }
  validates_presence_of :name, :description , :visibility, on: :create

  def generate_group_id
    unique_id = SecureRandom.hex(6)
    self.update(unique_group_id: unique_id)
  end
end
