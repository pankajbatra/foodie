class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  #        :trackable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtBlacklist
  validates_presence_of :name, :email, :encrypted_password, :mobile
  validates :email, uniqueness: { case_sensitive: false }, presence: true, allow_blank: false
end
