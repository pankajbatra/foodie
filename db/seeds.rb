# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
# %w(american chinese pizza italian indian japanese mexican thai korean lebanese).each do |name|
#   Cuisine.create! name: name
# end
# %w(restaurant customer).each do |role_name|
#   Role.create! name: role_name
# end

if Rails.env.test?
  %w(american chinese pizza italian indian japanese mexican thai korean lebanese).each do |name|
    Cuisine.create! name: name
  end
  %w(restaurant customer).each do |role_name|
    Role.create! name: role_name
  end
end

if Rails.env.production?
  10.times {
    customer = Fabricate(:user)
    restaurant = Fabricate(:restaurant)
    2.times {
      Fabricate(:order, restaurant: restaurant, user: customer)
    }
  }
end
