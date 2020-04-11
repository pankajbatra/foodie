Fabricator(:order) do
  transient :create_items => true
  restaurant { Fabricate(:restaurant) }
  user { Fabricate(:user) }
  status { Order.status.values[0] }
  payment_mode { Order.payment_mode.values.sample }
  payment_status { Order.payment_status.values.sample }

  customer_name { |attrs| "#{attrs[:user].name}" }
  customer_mobile { |attrs| "#{attrs[:user].mobile}" }
  customer_address { Faker::Address.street_address }
  customer_locality { Faker::Address.community }
  customer_latitude { Faker::Address.latitude }
  customer_longitude { Faker::Address.longitude }

  placed_at { Time.now }
  bill_number { Faker::Invoice::reference }
  special_request { Faker::Types::rb_string(words: 3) }

  delivery_charge { |attrs| "#{attrs[:restaurant].delivery_charge}" }
  packing_charge { |attrs| "#{attrs[:restaurant].packing_charge}" }

  after_create { |order, transients|
    if transients[:create_meals]
      # get random meals in this newly created restaurant
      meals = order.restaurant.meals.order('RAND()').limit(rand(1...2))
      meals.each do |meal|
        Fabricate(:order_item, meal: meal, order: order,
                               quantity: Faker::Number.within(range: 1..4),
                               meal_name: meal.name,
                               price_per_item: meal.price)
      end
    end
  }
end
