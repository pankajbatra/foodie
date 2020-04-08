require 'rails_helper'

RSpec.describe 'Restaurant APIs', type: :request do
  let!(:restaurant_user) { Fabricate(:restaurant_owner) }
  let!(:customer) { Fabricate(:user) }
  let(:url) { '/restaurants' }
  let(:get_url) { "#{url}/get" }
  let(:update_url) { "#{url}/update" }
  let(:open_url) { "#{url}/open" }
  let(:blacklist) {'/blacklist'}
  let(:params) do
    {
        name: 'Restaurant12',
        description: 'Best restaurant',
        min_delivery_amount: 200,
        avg_delivery_time: 50,
        delivery_charge: 20,
        packing_charge: 20,
        tax_percent: 5,
        phone_number: '9873241200',
        locality: 'Sector-49',
        address: 'Sapphire',
        latitude: '78.788833',
        longitude: '98.23232323',
        cuisine_ids: Cuisine.order('RAND()').limit(rand(2...5)).pluck(:id)
    }
  end

  describe 'POST /restaurants' do
    it 'request without JWT token' do
      post url, params: params
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with valid restaurant login' do
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)
      expect(json['name']).to eq params[:name]
      expect(json['latitude']).to eq params[:latitude]
      expect(json['cuisines'].size).to eq params[:cuisine_ids].size
      expect(json['meals'].size).to eq(0)
    end
    it 'recreating another restaurant for same restaurant user' do
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)
      post url, params: params, headers: {:Authorization => "Bearer #{@jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'creating with customer role' do
      jwt = confirm_and_login_user(customer)
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
  end

  describe 'GET /restaurants' do
    it 'request with valid restaurant login before restaurant create' do
      jwt = confirm_and_login_user(restaurant_user)
      get url, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
  end

  describe 'GET /restaurants' do
    let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user) }
    it 'request with valid restaurant login' do
      jwt = confirm_and_login_user(restaurant_user)
      get url, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json['name']).to eq restaurant.name
      expect(json['latitude']).to eq restaurant.latitude.to_s
      expect(json['cuisines'].size).to eq restaurant.cuisines.size
      expect(json['meals'].size).to eq restaurant.meals.size
    end
    it 'request with restaurant login but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get url, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request without JWT token' do
      get url
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with customer role' do
      jwt = confirm_and_login_user(customer)
      get url, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json[0]['name']).to eq restaurant.name
      expect(json[0]['latitude']).to eq restaurant.latitude.to_s
      expect(json[0]['cuisines'].size).to eq restaurant.cuisines.size
      expect(json[0]['meals'].size).to eq restaurant.meals.size
      expect(json.size).to eq(1)
    end
    it 'request with customer login but disabled restaurant' do
      jwt = confirm_and_login_user(customer)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get url, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eq(0)
    end
  end

  describe 'GET /restaurants/get' do
    it 'request with valid restaurant login before restaurant create' do
      jwt = confirm_and_login_user(restaurant_user)
      get get_url, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
  end

  describe 'GET /restaurants/get' do
    let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user) }
    it 'request with valid restaurant login' do
      jwt = confirm_and_login_user(restaurant_user)
      get get_url, params: {rid: restaurant.rid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json['name']).to eq restaurant.name
      expect(json['latitude']).to eq restaurant.latitude.to_s
      expect(json['cuisines'].size).to eq restaurant.cuisines.size
      expect(json['meals'].size).to eq restaurant.meals.size
    end
    it 'request with restaurant login but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get get_url, params: {rid: restaurant.rid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with restaurant login but not owned restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      temp_restaurant = Fabricate(:restaurant, name: "#{restaurant.name}1")
      get get_url, params: {rid: temp_restaurant.rid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
    end
    it 'request without JWT token' do
      get get_url, params: {rid: restaurant.rid}
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with customer role' do
      jwt = confirm_and_login_user(customer)
      get get_url, params: {rid: restaurant.rid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json['name']).to eq restaurant.name
      expect(json['latitude']).to eq restaurant.latitude.to_s
      expect(json['cuisines'].size).to eq restaurant.cuisines.size
      expect(json['meals'].size).to eq restaurant.meals.size
    end
    it 'request with customer login but disabled restaurant' do
      jwt = confirm_and_login_user(customer)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get get_url, params: {rid: restaurant.rid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with customer login with invalid param' do
      jwt = confirm_and_login_user(customer)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get get_url, params: {rid: '22323'}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
  end

  describe 'PUT /restaurants/update' do
    let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user) }
    it 'request with valid restaurant login' do
      jwt = confirm_and_login_user(restaurant_user)
      random_number = rand(5)
      put update_url, params: {rid: restaurant.rid, packing_charge: (restaurant.packing_charge + random_number)},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      expect(restaurant_user.restaurant.name).to eq restaurant.name
      expect(restaurant_user.restaurant.packing_charge).to eq (restaurant.packing_charge + random_number)
    end
    it 'request with restaurant login but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      put update_url, params: {rid: restaurant.rid, packing_charge: (restaurant.packing_charge*2)},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with restaurant login but invalid restaurant id' do
      jwt = confirm_and_login_user(restaurant_user)
      put update_url, params: {rid: '2323', packing_charge: (restaurant.packing_charge*2)},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with restaurant login but not owned restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      temp_restaurant = Fabricate(:restaurant, name: "#{restaurant.name}1")
      put update_url, params: {rid: temp_restaurant.rid, packing_charge: (restaurant.packing_charge*2)},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
    end
    it 'request without JWT token' do
      put update_url, params: {rid: restaurant.rid, packing_charge: (restaurant.packing_charge*2)}
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with customer role' do
      jwt = confirm_and_login_user(customer)
      put update_url, params: {rid: restaurant.rid, packing_charge: (restaurant.packing_charge*2)},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
  end

  describe 'PATCH /restaurants/open' do
    let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user) }
    it 'request with valid restaurant login - closing' do
      jwt = confirm_and_login_user(restaurant_user)
      patch open_url, params: {rid: restaurant.rid, open_for_delivery_now: false},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      expect(restaurant_user.restaurant.name).to eq restaurant.name
      expect(restaurant_user.restaurant.open_for_delivery_now).to eq false
    end
    it 'request with valid restaurant login - opening' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(open_for_delivery_now: false)
      patch open_url, params: {rid: restaurant.rid, open_for_delivery_now: true},
            headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      expect(restaurant_user.restaurant.name).to eq restaurant.name
      expect(restaurant_user.restaurant.open_for_delivery_now).to eq true
    end
    it 'request with restaurant login but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      patch open_url, params: {rid: restaurant.rid, open_for_delivery_now: false},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with restaurant login but invalid restaurant id' do
      jwt = confirm_and_login_user(restaurant_user)
      patch open_url, params: {rid: '2323', open_for_delivery_now: false},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with restaurant login but not owned restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      temp_restaurant = Fabricate(:restaurant, name: "#{restaurant.name}1")
      patch open_url, params: {rid: temp_restaurant.rid, open_for_delivery_now: false},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
    end
    it 'request without JWT token' do
      patch open_url, params: {rid: restaurant.rid, open_for_delivery_now: false}
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with customer role' do
      jwt = confirm_and_login_user(customer)
      patch open_url, params: {rid: restaurant.rid, open_for_delivery_now: false},
          headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
  end

  describe 'PATCH /blacklist' do
    let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user) }
    it 'request with valid restaurant login' do
      jwt = confirm_and_login_user(restaurant_user)
      patch blacklist, params: {uid: customer.uid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      restaurant_user.reload
      expect(restaurant.restaurant_blacklistings.count).to eq(1)
    end
    it 'request with restaurant login but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      patch blacklist, params: {uid: customer.uid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
    end
    it 'request without JWT token' do
      patch blacklist, params: {uid: customer.uid}
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'request with customer role' do
      jwt = confirm_and_login_user(customer)
      patch blacklist, params: {uid: customer.uid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'get restaurant list with customer role after blacklist' do
      jwt = confirm_and_login_user(restaurant_user)
      patch blacklist, params: {uid: customer.uid}, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      delete '/logout'
      expect(response).to have_http_status(200)
      jwt = confirm_and_login_user(customer)
      get url, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eq(0)
    end
  end
end