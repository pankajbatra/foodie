class Restaurant < ApplicationRecord
  extend Enumerize
  resourcify
  before_create :create_unique_identifier
  enumerize :status, in: [:Active, :Disabled], default: :Active
  belongs_to :owner, :class_name => 'User'
  validate :ensure_correct_owner

  def create_unique_identifier
    begin
      self.rid = SecureRandom.hex(5) # or whatever you chose like UUID tools
    end while self.class.exists?(:rid => rid)
  end

  def ensure_correct_owner(force_create = false)
    user = User.find(self.owner_id)
    if !user.is_restaurant_owner? || user.restaurant!=nil
      errors.add(:owner, 'is invalid')
    end
  end
end
