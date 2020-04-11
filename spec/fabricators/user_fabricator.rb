Fabricator(:user) do
  name { Faker::Name.name.truncate(30) }
  email { |attrs| "#{attrs[:name].parameterize}@example.com" } # email  Faker::Internet.email
  mobile Faker::Number.within(range: 9000000000..9999999999)
  password { Faker::Internet.password } # 'password'
end
