class OrderSerializer < ActiveModel::Serializer
  attributes :oid, :placed_at, :confirmed_at, :dispatched_at, :delivered_at, :received_at, :cancelled_at,
             :tax_amount, :delivery_charge, :packing_charge, :total_bill_amount, :status, :payment_mode, :payment_status,
             :special_request, :eta_after_confirm, :cancel_reason, :customer_mobile, :customer_address, :customer_locality,
             :customer_name
  attribute :bill_number, if: :is_restaurant_owner?
  attribute :customer_latitude, if: :is_restaurant_owner?
  attribute :customer_longitude, if: :is_restaurant_owner?
  attribute :remarks, if: :is_restaurant_owner?
  has_many :order_items
  belongs_to :restaurant, serializer: RestaurantSmallSerializer, if: :is_customer?
  belongs_to :user, serializer: UserSmallSerializer, if: :is_restaurant_owner?

  def is_restaurant_owner?
    scope.has_role? :restaurant
  end

  def is_customer?
    scope.has_role? :customer
  end

end
