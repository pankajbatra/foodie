class RestaurantSerializer < ActiveModel::Serializer
  attributes :rid, :name, :description, :open_for_delivery_now, :min_delivery_amount, :avg_delivery_time,
             :delivery_charge, :packing_charge, :tax_percent, :rating, :phone_number, :locality, :address, :latitude, :longitude
  has_many :cuisines
  has_many :meals
  # belongs_to :owner, if: :is_restaurant_owner?

  # scope orders to those created_by the current user
  # has_many :orders do
  #   object.orders.where(created_by: current_user)
  # end

  # def is_restaurant_owner?
  #   scope.has_role? :restaurant && scope.id == object.owner_id
  # end
end
