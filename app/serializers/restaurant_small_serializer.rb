class RestaurantSmallSerializer < ActiveModel::Serializer
  attributes :rid, :name, :phone_number, :locality, :address
end
