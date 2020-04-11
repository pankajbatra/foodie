class RestaurantBlacklisting < ApplicationRecord
  belongs_to :restaurant
  belongs_to :user

  validates_uniqueness_of :user_id, scope: %i[restaurant_id]
end
