Fabricator(:user) do
  name { Faker::Name.name }
  email  Faker::Internet.email
  mobile Faker::PhoneNumber.phone_number
  password 'password'
end