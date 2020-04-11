require 'rails_helper'

RSpec.describe 'Meals APIs', type: :request do
  let!(:restaurant_user) { Fabricate(:restaurant_owner) }
  let!(:customer) { Fabricate(:user) }
  let(:url) { '/meals' }
  let(:params) do
    {
      name: 'Dosa Sambhar',
      description: 'Masala Dosa with Sambhar',
      status: Meal.status.values[0],
      is_chef_special: false,
      is_veg: true,
      contains_egg: false,
      contains_meat: false,
      is_vegan: true,
      is_halal: true,
      course: Meal.course.values[1],
      ingredients: 'Rice, Potato, Vegetables',
      spice_level: Meal.spice_level.values[1],
      price: '120.0',
      serves: 1,
      cuisine_id: 5
    }
  end

  describe 'POST /meals' do
    let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user) }
    it 'request without JWT token' do
      post url, params: params
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with valid restaurant login but without a saved restaurant' do
      temp_user = Fabricate(:restaurant_owner)
      jwt = confirm_and_login_user(temp_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'request with valid restaurant login' do
      jwt = confirm_and_login_user(restaurant_user)
      prev_meal_count = restaurant.meals.size
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)
      expect(json['name']).to eq params[:name]
      expect(json['status']).to eq params[:status]
      expect(json['is_vegan']).to eq params[:is_vegan]
      expect(json['course']).to eq params[:course]
      expect(json['spice_level']).to eq params[:spice_level]
      expect(json['price']).to eq params[:price]
      expect(json['cuisine']['id']).to eq params[:cuisine_id]
      expect(restaurant.meals.size).to eq(prev_meal_count + 1)
    end
    it 'request with valid restaurant login but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'creating with customer role' do
      jwt = confirm_and_login_user(customer)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
  end

  describe 'GET /meals' do
    let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user, create_meals: false) }
    it 'request with valid restaurant login before restaurant create' do
      temp_user = Fabricate(:restaurant_owner)
      jwt = confirm_and_login_user(temp_user)
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with restaurant login but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with valid restaurant login' do
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eq(1)
      expect(json[0]['name']).to eq params[:name]
      expect(json[0]['status']).to eq params[:status]
      expect(json[0]['is_vegan']).to eq params[:is_vegan]
      expect(json[0]['course']).to eq params[:course]
      expect(json[0]['spice_level']).to eq params[:spice_level]
      expect(json[0]['price']).to eq params[:price]
      expect(json[0]['cuisine']['id']).to eq params[:cuisine_id]
    end
    it 'request without JWT token' do
      get url
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with customer role without rid param' do
      jwt = confirm_and_login_user(customer)
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with customer login but disabled restaurant' do
      jwt = confirm_and_login_user(customer)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get url, params: { rid: restaurant.rid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with customer login' do
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)
      delete '/logout'
      expect(response).to have_http_status(200)

      jwt = confirm_and_login_user(customer)
      get url, params: { rid: restaurant.rid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eq(1)
      expect(json[0]['name']).to eq params[:name]
      expect(json[0]['status']).to eq params[:status]
      expect(json[0]['is_vegan']).to eq params[:is_vegan]
      expect(json[0]['course']).to eq params[:course]
      expect(json[0]['spice_level']).to eq params[:spice_level]
      expect(json[0]['price']).to eq params[:price]
      expect(json[0]['cuisine']['id']).to eq params[:cuisine_id]
    end
  end

  describe 'PUT /meals/:meal_id' do
    it 'request with valid restaurant login' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user, create_meals: false)
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)

      random_number = rand(5)
      meal = restaurant.meals[0]
      new_price = meal.price + random_number
      put "#{url}/#{meal.id}",
          params: {
            status: Meal.status.values[1],
            is_chef_special: true,
            name: 'new name',
            course: Meal.course.values[5],
            spice_level: Meal.spice_level.values[0],
            price: (new_price),
            serves: 2,
            cuisine_id: 2
          },
          headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      meal.reload
      expect(meal.name).to eq 'new name'
      expect(meal.status).to eq Meal.status.values[1]
      expect(meal.is_chef_special).to eq true
      expect(meal.course).to eq Meal.course.values[5]
      expect(meal.spice_level).to eq Meal.spice_level.values[0]
      expect(meal.price).to eq new_price
      expect(meal.serves).to eq(2)
      expect(meal.cuisine_id).to eq(2)
    end
    it 'request with restaurant login but disabled restaurant' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user)
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      put "#{url}/#{restaurant.meals[0].id}",
          params: {
            status: Meal.status.values[1],
            is_chef_special: true,
            name: 'new name',
            course: Meal.course.values[5],
            spice_level: Meal.spice_level.values[0],
            serves: 2,
            cuisine_id: 2
          },
          headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
    end
    it 'request with restaurant login but invalid meal id' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user)
      jwt = confirm_and_login_user(restaurant_user)
      put "#{url}/#{restaurant.meals[0].id}1",
          params: {
            status: Meal.status.values[1],
            is_chef_special: true,
            name: 'new name',
            course: Meal.course.values[5],
            spice_level: Meal.spice_level.values[0],
            serves: 2,
            cuisine_id: 2
          },
          headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with restaurant login but not owned restaurant' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user)
      jwt = confirm_and_login_user(restaurant_user)
      temp_restaurant = Fabricate(:restaurant, name: "#{restaurant.name}1")
      put "#{url}/#{temp_restaurant.meals[0].id}1",
          params: {
            status: Meal.status.values[1],
            is_chef_special: true,
            name: 'new name',
            course: Meal.course.values[5],
            spice_level: Meal.spice_level.values[0],
            serves: 2,
            cuisine_id: 2
          },
          headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request without JWT token' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user)
      put "#{url}/#{restaurant.meals[0].id}1",
          params: {
            status: Meal.status.values[1],
            is_chef_special: true,
            name: 'new name',
            course: Meal.course.values[5],
            spice_level: Meal.spice_level.values[0],
            serves: 2,
            cuisine_id: 2
          }
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with customer role' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user)
      jwt = confirm_and_login_user(customer)
      put "#{url}/#{restaurant.meals[0].id}1",
          params: {
            status: Meal.status.values[1],
            is_chef_special: true,
            name: 'new name',
            course: Meal.course.values[5],
            spice_level: Meal.spice_level.values[0],
            serves: 2,
            cuisine_id: 2
          },
          headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'request with customer role - disabled meal should disappear' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user, create_meals: false)
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)
      delete '/logout'
      expect(response).to have_http_status(200)
      jwt = confirm_and_login_user(customer)
      get url, params: { rid: restaurant.rid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eq(1)
      delete '/logout'
      expect(response).to have_http_status(200)
      jwt = confirm_and_login_user(restaurant_user)
      put "#{url}/#{restaurant.meals[0].id}",
          params: { status: Meal.status.values[1] },
          headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      delete '/logout'
      expect(response).to have_http_status(200)
      jwt = confirm_and_login_user(customer)
      get url, params: { rid: restaurant.rid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eq(0)
    end
  end

  describe 'PATCH /meals/:meal_id' do
    it 'request with valid restaurant login - out to stock' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user, create_meals: false)
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)

      patch "#{url}/#{restaurant.meals[0].id}",
            params: { status: Meal.status.values[2] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      restaurant.meals.reload
      expect(restaurant.meals[0].status).to eq Meal.status.values[2]
    end
    it 'request with valid restaurant login - active' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user, create_meals: false)
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)

      patch "#{url}/#{restaurant.meals[0].id}",
            params: { status: Meal.status.values[0] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      restaurant.meals.reload
      expect(restaurant.meals[0].status).to eq Meal.status.values[0]
    end
    it 'request with valid restaurant login - disabled' do
      restaurant = Fabricate(:restaurant, owner: restaurant_user, create_meals: false)
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)

      patch "#{url}/#{restaurant.meals[0].id}",
            params: { status: Meal.status.values[1] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      restaurant.meals.reload
      expect(restaurant.meals[0].status).to eq Meal.status.values[1]
    end
  end
end
