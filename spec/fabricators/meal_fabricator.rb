Fabricator(:meal) do
  name { Faker::Food::dish.truncate(50)}
  status  { Meal.status.values[0] }
  description { Faker::Food::description.truncate(200) }
  is_chef_special { Faker::Boolean::boolean }

  is_veg { false }
  contains_egg { Faker::Boolean::boolean }
  contains_meat { Faker::Boolean::boolean }
  is_vegan { false }

  is_halal { Faker::Boolean::boolean }
  course { Meal.course.values.sample }
  spice_level { Meal.spice_level.values.sample }
  ingredients { Faker::Food::ingredient.truncate(200) }
  price { Faker::Commerce::price}
  serves { Faker::Number::non_zero_digit}

  cuisine
  restaurant
end