class User < ApplicationRecord
  extend Enumerize
  rolify
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
  validates :name, :presence => true, :length => {:minimum => 3, :maximum => 30}
  validates_format_of :name, :with => /\A[^0-9`!@#\$%\^&*+_=]+\z/
  validates :mobile,:presence => true,
            :numericality => true,
            :length => { :minimum => 10, :maximum => 15 }
  after_create :assign_default_role
  enumerize :status, in: [:Active, :Disabled], default: :Active

  has_many :orders
  has_many :restaurant_blacklistings, :dependent => :destroy

  has_one :restaurant, :class_name => 'Restaurant', :foreign_key => 'owner_id', :dependent => :destroy

  def is_restaurant_owner?
    has_role? :restaurant
  end

  def is_blacklisted(restaurant_id)
    blacklisted = restaurant_blacklistings.find_by_restaurant_id(restaurant_id)
    blacklisted != nil
  end

  def is_customer?
    has_role? :customer
  end

  def assign_default_role
    self.add_role(:customer) if self.roles.blank?
  end

  def role_names=(role)
    roles = Role.where('name IN (?)', role)
    self.roles << roles
  end

  def active_for_authentication?
    super && self.account_active?
  end

  def account_active?
    status == User.status.values[0]
  end

  before_create :create_unique_identifier

  def create_unique_identifier
    begin
      self.uid = SecureRandom.hex(5)
    end while self.class.exists?(:uid => uid)
  end

  def inactive_message
    'Sorry, this account has been deactivated.'
  end

end
