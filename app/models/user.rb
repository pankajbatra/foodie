class User < ApplicationRecord
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
  validates_presence_of :name
  validates_format_of :name, :with => /\A[^0-9`!@#\$%\^&*+_=]+\z/
  validates :mobile,:presence => true,
            :numericality => true,
            :length => { :minimum => 10, :maximum => 15 }
  after_create :assign_default_role

  def assign_default_role
    self.add_role(:customer) if self.roles.blank?
  end

  def role_names=(role)
    roles = Role.where("name IN (?)", role)
    self.roles << roles
  end

end
