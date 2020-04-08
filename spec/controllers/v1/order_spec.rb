require 'rails_helper'

RSpec.describe 'Order APIs', type: :request do
  let!(:restaurant_user) { Fabricate(:restaurant_owner) }
  let!(:customer) { Fabricate(:user) }
  let!(:restaurant) { Fabricate(:restaurant, owner: restaurant_user) }
  let(:url) { '/orders' }
  let(:params) { generate_order_params(restaurant, customer) }

  describe 'POST /orders' do
    it 'not logged in' do
      post url, params: params
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'You need to sign in or sign up before continuing.'
    end
    it 'restaurant id not sent' do
      jwt = confirm_and_login_user(customer)
      post url, params: params.except(:rid), headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'invalid restaurant id sent' do
      jwt = confirm_and_login_user(customer)
      new_params = params.except(:rid)
      new_params.store(:rid, 'random_value')
      post url, params: new_params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'restaurant user trying to create order' do
      jwt = confirm_and_login_user(restaurant_user)
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'disabled user trying to create order' do
      jwt = confirm_and_login_user(customer)
      customer.update_columns(status: User.status.values[1])
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(401)
      expect(response.body).to eq 'Sorry, this account has been deactivated.'
    end
    it 'user trying to create order on disabled restaurant' do
      jwt = confirm_and_login_user(customer)
      restaurant.update_columns(status: Restaurant.status.values[1])
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'user trying to create order on closed for delivery restaurant' do
      jwt = confirm_and_login_user(customer)
      restaurant.update_columns(open_for_delivery_now: false)
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'You don\'t have permission for this operation'
    end
    it 'blacklisted user trying to create order' do
      jwt = confirm_and_login_user(customer)
      RestaurantBlacklisting.create!({restaurant_id: restaurant.id, user_id: customer.id})
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'User is blacklisted'
    end
    it 'no meals provided in order data' do
      jwt = confirm_and_login_user(customer)
      post url, params: params.except(:order_items_attributes), headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'No meals provided'
      end
    it 'no meals provided in order data' do
      jwt = confirm_and_login_user(customer)
      new_params = params.except(:total_bill_amount)
      new_params.store(:total_bill_amount, (restaurant.min_delivery_amount - 1))
      post url, params: new_params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(403)
      expect(json['message']).to eq 'Minimum order amount not provided'
    end
    it 'out of stock meal added' do
      jwt = confirm_and_login_user(customer)
      Meal.find_by_id(params[:order_items_attributes][0][:meal_id]).update_columns(status: Meal.status.values[2])
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('out of stock')
    end
    it 'disabled meal added' do
      jwt = confirm_and_login_user(customer)
      Meal.find_by_id(params[:order_items_attributes][0][:meal_id]).update_columns(status: Meal.status.values[1])
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('out of stock')
    end
    it 'invalid meal name sent' do
      jwt = confirm_and_login_user(customer)
      Meal.find_by_id(params[:order_items_attributes][0][:meal_id]).update_columns(name: 'some_random_name')
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Order items is invalid')
    end
    it 'invalid meal price sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:order_items_attributes][0][:price_per_item] = (new_params[:order_items_attributes][0][:price_per_item] + 0.1)
      post url, params: new_params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Order items is invalid')
    end
    it 'invalid sub order amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:order_items_attributes][0][:sub_order_amount] = (new_params[:order_items_attributes][0][:sub_order_amount] + 0.1)
      post url, params: new_params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Order items is invalid')
    end
    it 'invalid tax amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:tax_amount] = (new_params[:tax_amount] + 0.1)
      post url, params: new_params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Tax amount is invalid')
    end
    it 'invalid delivery charge amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:delivery_charge] = (new_params[:delivery_charge] + 1)
      post url, params: new_params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Delivery charge is invalid')
    end
    it 'invalid packing charge amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:packing_charge] = (new_params[:packing_charge] + 1)
      post url, params: new_params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Packing charge is invalid')
    end
    it 'invalid total bill amount sent' do
      jwt = confirm_and_login_user(customer)
      new_params = generate_order_params(restaurant, customer)
      new_params[:total_bill_amount] = (new_params[:total_bill_amount] + 0.1)
      post url, params: new_params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(422)
      expect(json['message']).to include('Total bill amount is invalid')
    end
    it 'valid order data' do
      jwt = confirm_and_login_user(customer)
      post url, params: params, headers: {:Authorization => "Bearer #{jwt}" }
      expect(response).to have_http_status(201)

  #     {
  #         "oid": "4984296c8b1293",
  #         "placed_at": "2020-04-08T20:20:37.000Z",
  #         "confirmed_at": null,
  #         "dispatched_at": null,
  #         "delivered_at": null,
  #         "received_at": null,
  #         "cancelled_at": null,
  #         "tax_amount": "0.0",
  #         "delivery_charge": 0,
  #         "packing_charge": 0,
  #         "total_bill_amount": "360.0",
  #         "status": "Placed",
  #         "payment_mode": "Wallet",
  #         "payment_status": "Pending",
  #         "special_request": "5sdsdsd",
  #         "eta_after_confirm": null,
  #         "cancel_reason": null,
  #         "customer_mobile": "9873241200",
  #         "customer_address": "S-219, Sector-49",
  #         "customer_locality": "Sector-49",
  #         "customer_name": "Restaurant12",
  #         "order_items": [
  #             {
  #                 "quantity": 1,
  #                 "meal_name": "Chole Bature",
  #                 "price_per_item": "120.0",
  #                 "sub_order_amount": "120.0"
  #             },
  #             {
  #                 "quantity": 2,
  #                 "meal_name": "Dosa Sambhar",
  #                 "price_per_item": "120.0",
  #                 "sub_order_amount": "240.0"
  #             }
  #         ],
  #         "restaurant": {
  #             "rid": "40fe02d992",
  #             "name": "Resta1",
  #             "phone_number": null,
  #             "locality": "Sector 48",
  #             "address": null
  #         }
  #     }
  #     expect(json['name']).to eq params[:name]
  #     expect(json['latitude']).to eq params[:latitude]
  #     expect(json['cuisines'].size).to eq params[:cuisine_ids].size
  #     expect(json['meals'].size).to eq(0)
    end
  end

end