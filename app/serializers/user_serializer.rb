class UserSerializer < ActiveModel::Serializer
  attributes :uid, :name
  attribute :email, if: :is_current_user?
  attribute :mobile, if: :is_current_user?
  attribute :status, if: :is_current_user?
  belongs_to :roles, if: :is_current_user?

  # belongs_to :location

  # scope orders to those created_by the current user
  # has_many :orders do
  #   object.orders.where(created_by: current_user)
  # end

  # attribute :private_data, if: :is_current_user?
  # attribute :another_private_data, if: -> { scope.admin? }
  #

  def is_current_user?
    object.id == scope.id
  end
end
