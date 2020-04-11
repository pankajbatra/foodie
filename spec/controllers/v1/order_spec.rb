require 'rails_helper'

RSpec.describe 'Order APIs', type: :request do
  let!(:restaurant_user) { Fabricate(:restaurant_owner) }
  let!(:customer) { Fabricate(:user) }
  let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user) }
  let(:url) { '/orders' }
  let(:get_url) { '/orders/get' }
  let(:update_url) { '/orders/update' }
  let(:params) { generate_order_params(restaurant, customer) }

  describe 'POST /orders' do
    it 'not logged in' do
      post url, params: params
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'restaurant id not sent' do
      jwt = confirm_and_login_user(customer)
      post url, params: params.except(:rid), headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'invalid restaurant id sent' do
      jwt = confirm_and_login_user(customer)
      new_params = params.except(:rid)
      new_params.store(:rid, 'random_value')
      post url, params: new_params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'restaurant user trying to create order' do
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'disabled user trying to create order' do
      jwt = confirm_and_login_user(customer)
      customer.update_columns(status: User.status.values[1])
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'Sorry, this account has been deactivated.'
    end
    it 'user trying to create order on disabled restaurant' do
      jwt = confirm_and_login_user(customer)
      restaurant.update_columns(status: Restaurant.status.values[1])
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'user trying to create order on closed for delivery restaurant' do
      jwt = confirm_and_login_user(customer)
      restaurant.update_columns(open_for_delivery_now: false)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'blacklisted user trying to create order' do
      jwt = confirm_and_login_user(customer)
      RestaurantBlacklisting.create!({ restaurant_id: restaurant.id, user_id: customer.id })
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'User is blacklisted'
    end
    it 'no meals provided in order data' do
      jwt = confirm_and_login_user(customer)
      post url,
           params: params.except(:order_items_attributes),
           headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'No meals provided'
    end
    it 'min order amount not reached' do
      jwt = confirm_and_login_user(customer)
      new_params = params.except(:total_bill_amount)
      new_params.store(:total_bill_amount, (restaurant.min_delivery_amount - 1))
      post url, params: new_params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'Minimum order amount not provided'
    end
    it 'out of stock meal added' do
      jwt = confirm_and_login_user(customer)
      Meal.find_by_id(params[:order_items_attributes][0][:meal_id]).update_columns(status: Meal.status.values[2])
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('out of stock')
    end
    it 'disabled meal added' do
      jwt = confirm_and_login_user(customer)
      Meal.find_by_id(params[:order_items_attributes][0][:meal_id]).update_columns(status: Meal.status.values[1])
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('out of stock')
    end
    it 'invalid meal name sent' do
      jwt = confirm_and_login_user(customer)
      Meal.find_by_id(params[:order_items_attributes][0][:meal_id]).update_columns(name: 'some_random_name')
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Order items is invalid')
    end
    it 'invalid meal price sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:order_items_attributes][0][:price_per_item] =
        (new_params[:order_items_attributes][0][:price_per_item] + 0.1)
      post url, params: new_params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Order items is invalid')
    end
    it 'invalid sub order amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:order_items_attributes][0][:sub_order_amount] =
        (new_params[:order_items_attributes][0][:sub_order_amount] + 0.1)
      post url, params: new_params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Order items is invalid')
    end
    it 'invalid tax amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:tax_amount] = (new_params[:tax_amount] + 0.1)
      post url, params: new_params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Tax amount is invalid')
    end
    it 'invalid delivery charge amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:delivery_charge] = (new_params[:delivery_charge] + 1)
      post url, params: new_params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Delivery charge is invalid')
    end
    it 'invalid packing charge amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:packing_charge] = (new_params[:packing_charge] + 1)
      post url, params: new_params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Packing charge is invalid')
    end
    it 'invalid total bill amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:total_bill_amount] = (new_params[:total_bill_amount] + 0.1)
      post url, params: new_params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Total bill amount is invalid')
    end
    it 'valid order data' do
      jwt = confirm_and_login_user(customer)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)
      expect(json['oid'].length).to be > 4
      expect(json['placed_at'].to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(json['confirmed_at']).to eql nil
      expect(json['dispatched_at']).to eql nil
      expect(json['delivered_at']).to eql nil
      expect(json['received_at']).to eql nil
      expect(json['cancelled_at']).to eql nil
      expect(json['eta_after_confirm']).to eql nil
      expect(json['cancel_reason']).to eql nil

      expect(json['tax_amount']).to eql params[:tax_amount].round(2).to_s
      expect(json['delivery_charge']).to eql params[:delivery_charge]
      expect(json['packing_charge']).to eql params[:packing_charge]
      expect(json['total_bill_amount']).to eql params[:total_bill_amount].round(2).to_s
      expect(json['payment_mode']).to eql params[:payment_mode]
      expect(json['special_request']).to eql params[:special_request]

      expect(json['customer_name']).to eql params[:customer_name]
      expect(json['customer_mobile']).to eql params[:customer_mobile]
      expect(json['customer_address']).to eql params[:customer_address]
      expect(json['customer_locality']).to eql params[:customer_locality]

      expect(json['status']).to eql Order.status.values[0]
      expect(json['payment_status']).to eql Order.payment_status.values[0]

      expect(json['restaurant']['rid']).to eql restaurant.rid
      expect(json['restaurant']['name']).to eql restaurant.name
      expect(json['restaurant']['phone_number']).to eql restaurant.phone_number
      expect(json['restaurant']['locality']).to eql restaurant.locality
      expect(json['restaurant']['address']).to eql restaurant.address

      expect(json['order_items'].size).to eq params[:order_items_attributes].size
    end
  end

  describe 'GET /orders' do
    it 'not logged in' do
      get url
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'restaurant user but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'request with valid restaurant login but without a saved restaurant' do
      temp_user = Fabricate(:restaurant_owner)
      jwt = confirm_and_login_user(temp_user)
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'restaurant user without any order' do
      jwt = confirm_and_login_user(restaurant_user)
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eql(0)
    end
    it 'customer without any order' do
      jwt = confirm_and_login_user(customer)
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eql(0)
    end
    it 'customer after placing order' do
      jwt = confirm_and_login_user(customer)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)

      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eql(1)
      expect(json[0]['oid'].length).to be > 4
      expect(json[0]['placed_at'].to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(json[0]['confirmed_at']).to eql nil
      expect(json[0]['dispatched_at']).to eql nil
      expect(json[0]['delivered_at']).to eql nil
      expect(json[0]['received_at']).to eql nil
      expect(json[0]['cancelled_at']).to eql nil
      expect(json[0]['eta_after_confirm']).to eql nil
      expect(json[0]['cancel_reason']).to eql nil

      expect(json[0]['tax_amount']).to eql params[:tax_amount].round(2).to_s
      expect(json[0]['delivery_charge']).to eql params[:delivery_charge]
      expect(json[0]['packing_charge']).to eql params[:packing_charge]
      expect(json[0]['total_bill_amount']).to eql params[:total_bill_amount].round(2).to_s
      expect(json[0]['payment_mode']).to eql params[:payment_mode]
      expect(json[0]['special_request']).to eql params[:special_request]

      expect(json[0]['customer_name']).to eql params[:customer_name]
      expect(json[0]['customer_mobile']).to eql params[:customer_mobile]
      expect(json[0]['customer_address']).to eql params[:customer_address]
      expect(json[0]['customer_locality']).to eql params[:customer_locality]

      expect(json[0]['status']).to eql Order.status.values[0]
      expect(json[0]['payment_status']).to eql Order.payment_status.values[0]

      expect(json[0]['restaurant']['rid']).to eql restaurant.rid
      expect(json[0]['restaurant']['name']).to eql restaurant.name
      expect(json[0]['restaurant']['phone_number']).to eql restaurant.phone_number
      expect(json[0]['restaurant']['locality']).to eql restaurant.locality
      expect(json[0]['restaurant']['address']).to eql restaurant.address

      expect(json[0]['order_items'].size).to eq params[:order_items_attributes].size
    end

    it 'restaurant user after placing order' do
      jwt = confirm_and_login_user(customer)
      post url, params: params, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)
      delete '/logout'

      jwt = confirm_and_login_user(restaurant_user)
      get url, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json.size).to eql(1)
      expect(json[0]['oid'].length).to be > 4
      expect(json[0]['placed_at'].to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(json[0]['confirmed_at']).to eql nil
      expect(json[0]['dispatched_at']).to eql nil
      expect(json[0]['delivered_at']).to eql nil
      expect(json[0]['received_at']).to eql nil
      expect(json[0]['cancelled_at']).to eql nil
      expect(json[0]['eta_after_confirm']).to eql nil
      expect(json[0]['cancel_reason']).to eql nil

      expect(json[0]['tax_amount']).to eql params[:tax_amount].round(2).to_s
      expect(json[0]['delivery_charge']).to eql params[:delivery_charge]
      expect(json[0]['packing_charge']).to eql params[:packing_charge]
      expect(json[0]['total_bill_amount']).to eql params[:total_bill_amount].round(2).to_s
      expect(json[0]['payment_mode']).to eql params[:payment_mode]
      expect(json[0]['special_request']).to eql params[:special_request]

      expect(json[0]['customer_name']).to eql params[:customer_name]
      expect(json[0]['customer_mobile']).to eql params[:customer_mobile]
      expect(json[0]['customer_address']).to eql params[:customer_address]
      expect(json[0]['customer_locality']).to eql params[:customer_locality]

      expect(json[0]['status']).to eql Order.status.values[0]
      expect(json[0]['payment_status']).to eql Order.payment_status.values[0]

      expect(json[0]['user']['uid']).to eql customer.uid
      expect(json[0]['user']['name']).to eql customer.name

      expect(json[0]['bill_number']).to eql params[:bill_number]
      expect(json[0]['customer_latitude']).to eql params[:customer_latitude].to_s
      expect(json[0]['customer_longitude']).to eql params[:customer_longitude].to_s
      expect(json[0]['remarks']).to eql params[:remarks]

      expect(json[0]['order_items'].size).to eq params[:order_items_attributes].size
    end
  end

  describe 'GET /orders/get' do
    let!(:order) { Fabricate(:order, restaurant: restaurant, user: customer) }
    it 'not logged in' do
      get get_url, params: { oid: order.oid }
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'restaurant user but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      get get_url, params: { oid: order.oid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'restaurant user but invalid oid' do
      jwt = confirm_and_login_user(restaurant_user)
      get get_url, params: { oid: 'random' }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end
    it 'restaurant login but without a saved restaurant' do
      temp_user = Fabricate(:restaurant_owner)
      jwt = confirm_and_login_user(temp_user)
      get get_url, params: { oid: order.oid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'restaurant login but trying another restaurant\'s order' do
      jwt = confirm_and_login_user(Fabricate(:restaurant).owner)
      get get_url, params: { oid: order.oid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end

    it 'restaurant user ' do
      jwt = confirm_and_login_user(restaurant_user)
      get get_url, params: { oid: order.oid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json['oid']).to eql order.oid
      expect(json['placed_at'].to_date).to eql order.placed_at.to_date
      expect(json['confirmed_at']).to eql nil
      expect(json['dispatched_at']).to eql nil
      expect(json['delivered_at']).to eql nil
      expect(json['received_at']).to eql nil
      expect(json['cancelled_at']).to eql nil
      expect(json['eta_after_confirm']).to eql nil
      expect(json['cancel_reason']).to eql nil

      expect(json['tax_amount']).to eql order.tax_amount.round(2).to_s
      expect(json['delivery_charge']).to eql order.delivery_charge
      expect(json['packing_charge']).to eql order.packing_charge
      expect(json['total_bill_amount']).to eql order.total_bill_amount.round(2).to_s
      expect(json['payment_mode']).to eql order.payment_mode
      expect(json['special_request']).to eql order.special_request

      expect(json['customer_name']).to eql order.customer_name
      expect(json['customer_mobile']).to eql order.customer_mobile
      expect(json['customer_address']).to eql order.customer_address
      expect(json['customer_locality']).to eql order.customer_locality

      expect(json['status']).to eql Order.status.values[0]
      expect(json['payment_status']).to eql order.payment_status

      expect(json['user']['uid']).to eql customer.uid
      expect(json['user']['name']).to eql customer.name

      expect(json['bill_number']).to eql order.bill_number
      expect(json['customer_latitude']).to eql order.customer_latitude.to_s
      expect(json['customer_longitude']).to eql order.customer_longitude.to_s
      expect(json['remarks']).to eql order.remarks

      expect(json['order_items'].size).to eq order.order_items.size
    end

    it 'customer login but trying another user\'s order' do
      jwt = confirm_and_login_user(Fabricate(:user))
      get get_url, params: { oid: order.oid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end

    it 'customer login' do
      jwt = confirm_and_login_user(customer)
      get get_url, params: { oid: order.oid }, headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(200)
      expect(json['oid']).to eql order.oid
      expect(json['placed_at'].to_date).to eql order.placed_at.to_date
      expect(json['confirmed_at']).to eql nil
      expect(json['dispatched_at']).to eql nil
      expect(json['delivered_at']).to eql nil
      expect(json['received_at']).to eql nil
      expect(json['cancelled_at']).to eql nil
      expect(json['eta_after_confirm']).to eql nil
      expect(json['cancel_reason']).to eql nil

      expect(json['tax_amount']).to eql order.tax_amount.round(2).to_s
      expect(json['delivery_charge']).to eql order.delivery_charge
      expect(json['packing_charge']).to eql order.packing_charge
      expect(json['total_bill_amount']).to eql order.total_bill_amount.round(2).to_s
      expect(json['payment_mode']).to eql order.payment_mode
      expect(json['special_request']).to eql order.special_request

      expect(json['customer_name']).to eql order.customer_name
      expect(json['customer_mobile']).to eql order.customer_mobile
      expect(json['customer_address']).to eql order.customer_address
      expect(json['customer_locality']).to eql order.customer_locality

      expect(json['status']).to eql Order.status.values[0]
      expect(json['payment_status']).to eql order.payment_status

      expect(json['remarks']).to eql order.remarks

      expect(json['order_items'].size).to eq order.order_items.size

      expect(json['restaurant']['rid']).to eql restaurant.rid
      expect(json['restaurant']['name']).to eql restaurant.name
      expect(json['restaurant']['phone_number']).to eql restaurant.phone_number
      expect(json['restaurant']['locality']).to eql restaurant.locality
      expect(json['restaurant']['address']).to eql restaurant.address
    end
  end

  describe 'PATCH /orders/update' do
    let!(:order) { Fabricate(:order, restaurant: restaurant, user: customer) }

    it 'restaurant user but invalid oid' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: { oid: 'random', status: Order.status.values[1] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end

    it 'customer user but invalid oid' do
      jwt = confirm_and_login_user(customer)
      patch update_url,
            params: { oid: 'random', status: Order.status.values[5] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(404)
    end

    it 'restaurant user trying to mark status as placed' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[0] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user trying to mark status as placed' do
      jwt = confirm_and_login_user(customer)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[0] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'restaurant user trying without any status param' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: { oid: order.oid },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user trying without any status param' do
      jwt = confirm_and_login_user(customer)
      patch update_url,
            params: { oid: order.oid },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer login but trying another user\'s order' do
      jwt = confirm_and_login_user(Fabricate(:user))
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[5] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'restaurant login but trying another restaurant\'s order' do
      jwt = confirm_and_login_user(Fabricate(:restaurant).owner)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[1] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user trying to mark processing' do
      jwt = confirm_and_login_user(customer)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[1] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user trying to mark in route' do
      jwt = confirm_and_login_user(customer)
      order.update_columns(status: Order.status.values[1])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[2] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user trying to mark in delivered' do
      jwt = confirm_and_login_user(customer)
      order.update_columns(status: Order.status.values[2])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[3] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user trying to mark in received without previous status delivered' do
      jwt = confirm_and_login_user(customer)
      # order.update_columns(status: Order.status.values[3])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[4] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user marking received with previous status delivered' do
      jwt = confirm_and_login_user(customer)
      order.update_columns(status: Order.status.values[3])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[4] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      order.reload
      expect(order.received_at.to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(order.status).to eql Order.status.values[4]
    end

    it 'restautant user trying to mark received' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[3])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[4] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user trying to mark in cancelled without previous status placed' do
      jwt = confirm_and_login_user(customer)
      order.update_columns(status: Order.status.values[1])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[5] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'customer user marking cancelled with previous status placed' do
      jwt = confirm_and_login_user(customer)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[5] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      order.reload
      expect(order.cancelled_at.to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(order.status).to eql Order.status.values[5]
      expect(order.cancel_reason).to eql Order.cancel_reason.values[0]
    end

    it 'request with restaurant login but disabled restaurant' do
      jwt = confirm_and_login_user(restaurant_user)
      restaurant.update_columns(status: Restaurant.status.values[1])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[1] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'request with valid restaurant login before restaurant create' do
      temp_user = Fabricate(:restaurant_owner)
      jwt = confirm_and_login_user(temp_user)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[1] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'cancelling order with restaurant login but delivered order' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[3])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[5] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'cancelling order with restaurant login but received order' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[4])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[5] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'cancelling order with restaurant login but already cancelled order' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[5])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[5] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'cancelling order with restaurant login but without reason' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[5] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('Invalid cancellation reason')
    end

    it 'cancelling order with restaurant login but with customer cancel reason' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: {
              oid: order.oid,
              status: Order.status.values[5],
              cancel_reason: Order.cancel_reason.values[0]
            },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('Invalid cancellation reason')
    end

    it 'cancelling order with restaurant login but with damaged reason' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: {
              oid: order.oid,
              status: Order.status.values[5],
              cancel_reason: Order.cancel_reason.values[7]
            },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('Invalid cancellation reason')
    end

    it 'cancelling order with restaurant login but with undelivered reason' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: {
              oid: order.oid,
              status: Order.status.values[5],
              cancel_reason: Order.cancel_reason.values[8]
            },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('Invalid cancellation reason')
    end

    it 'cancelling order with restaurant login but with store closed reason after processing started' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[1])
      patch update_url,
            params: {
              oid: order.oid,
              status: Order.status.values[5],
              cancel_reason: Order.cancel_reason.values[2]
            },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('Invalid cancellation reason')
    end

    it 'cancelling order with restaurant login but with invalid reason after in route' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[2])
      patch update_url,
            params: {
              oid: order.oid,
              status: Order.status.values[5],
              cancel_reason: Order.cancel_reason.values[1]
            },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('Invalid cancellation reason')
      patch update_url,
            params: {
              oid: order.oid,
              status: Order.status.values[5],
              cancel_reason: Order.cancel_reason.values[2]
            },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('Invalid cancellation reason')
      patch update_url,
            params: {
              oid: order.oid,
              status: Order.status.values[5],
              cancel_reason: Order.cancel_reason.values[3]
            },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('Invalid cancellation reason')
    end

    it 'restaurant user marking cancelled with previous status placed' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: {
              oid: order.oid,
              status: Order.status.values[5],
              cancel_reason: Order.cancel_reason.values[2],
              remarks: 'store closed'
            },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      order.reload
      expect(order.cancelled_at.to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(order.status).to eql Order.status.values[5]
      expect(order.cancel_reason).to eql Order.cancel_reason.values[2]
      expect(order.remarks).to eql 'store closed'
    end

    it 'restaurant user trying to mark in processing without previous status not placed' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[2])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[1] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'restaurant user marking processing with previous status placed' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[1] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      order.reload
      expect(order.confirmed_at.to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(order.status).to eql Order.status.values[1]
    end

    it 'restaurant user trying to mark in route with previous status not processing' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[3])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[2] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'restaurant user marking in route with previous status processing' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[1])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[2] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      order.reload
      expect(order.dispatched_at.to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(order.status).to eql Order.status.values[2]
    end

    it 'restaurant user trying to mark delivered with previous status not in route' do
      jwt = confirm_and_login_user(restaurant_user)
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[3] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to include('You don\'t have permission for this operation')
    end

    it 'restaurant user marking delivered with previous status in route' do
      jwt = confirm_and_login_user(restaurant_user)
      order.update_columns(status: Order.status.values[2])
      patch update_url,
            params: { oid: order.oid, status: Order.status.values[3] },
            headers: { :Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(204)
      order.reload
      expect(order.delivered_at.to_datetime.utc.to_date.to_s).to eql Time.now.utc.to_date.to_s
      expect(order.status).to eql Order.status.values[3]
    end
  end
end
