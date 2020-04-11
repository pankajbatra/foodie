class OrderItemSerializer < ActiveModel::Serializer
  attributes :quantity, :meal_name, :price_per_item, :sub_order_amount
end
