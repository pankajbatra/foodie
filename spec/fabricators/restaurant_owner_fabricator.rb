Fabricator(:restaurant_owner, from: :user) do
  after_save {|user|
    user.remove_role :customer
    user.add_role :restaurant
  }
end
