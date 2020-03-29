Fabricator(:user) do
  name { Faker::Name.name }
  email  Faker::Internet.email
  mobile Faker::Number.within(range: 9000000000..9999999999)
  password 'password'
end