class UserSerializer < ActiveModel::Serializer
  attributes :uid, :name
  attribute :email, if: :is_current_user?
  attribute :mobile, if: :is_current_user?
  attribute :status, if: :is_current_user?
  belongs_to :roles, if: :is_current_user?
  belongs_to :restaurant, if: :is_restaurant_owner?

  # scope orders to those created_by the current user
  # has_many :orders do
  #   object.orders.where(created_by: current_user)
  # end

  def is_restaurant_owner?
    scope.has_role? :restaurant
  end

  def is_current_user?
    object.id == scope.id
  end
end
