Fabricator(:restaurant) do
  transient :create_meals => true
  name {Faker::Restaurant::name.truncate(100)}
  description {Faker::Restaurant::description.truncate(100)}
  status {Restaurant.status.values[0]}
  open_for_delivery_now {true}
  # open_for_delivery_now { Faker::Boolean::boolean }
  delivery_charge {Faker::Number.within(range: 0..90)}
  packing_charge {Faker::Number.within(range: 0..100)}
  tax_percent {Faker::Number.within(range: 0..30)}
  phone_number Faker::Number.within(range: 9000000000..9999999999)
  locality {Faker::Address.community.truncate(100)}
  address {Faker::Address.street_address.truncate(200)}
  latitude {Faker::Address.latitude}
  longitude {Faker::Address.longitude}

  owner {Fabricate(:restaurant_owner)}

  after_create {|restaurant, transients|
    cuisines = Cuisine.order('RAND()').limit(rand(2...3))
    cuisines.each do |cusi|
      Fabricate(:restaurants_cuisine, restaurant: restaurant, cuisine: cusi)
      if transients[:create_meals]
        rand(3...5).times {
          Fabricate(:meal, restaurant: restaurant, cuisine: cusi)
        }
      end
    end
  }
end