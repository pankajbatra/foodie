module Request
  module AuthenticationHelper
    def json
      JSON.parse(response.body)
    end

    def confirm_and_login_user(user)
      post '/login',
           params: {
             user: {
               email: user.email,
               password: user.password
             }
           }
      token_from_request = response.headers['Authorization'].split(' ').last
      JWT.decode(
        token_from_request,
        Rails.application.credentials.devise_jwt_secret_key,
        true
      )
    end

    def generate_order_params(restaurant, customer)
      params = {
        rid: restaurant.rid,
        payment_mode: Order.payment_mode.values[2],
        special_request: 'Please donn\'t ring the bell',
        customer_name: customer.name,
        customer_mobile: customer.mobile,
        customer_address: 'Xyz, PQR Street, Lane 8, Broadway 435',
        customer_locality: 'Huson Lane 44',
        customer_latitude: 78.788833,
        customer_longitude: 98.23232323
      }
      params[:order_items_attributes] = Array.new
      i = 0
      total_order_amount = 0
      meals = restaurant.meals.order('RAND()').limit(rand(1...4))
      meals.each do |meal|
        params[:order_items_attributes][i] = Hash.new
        qty = rand(1...3)
        params[:order_items_attributes][i][:meal_id] = meal.id
        params[:order_items_attributes][i][:quantity] = qty
        params[:order_items_attributes][i][:meal_name] = meal.name
        params[:order_items_attributes][i][:price_per_item] = meal.price
        params[:order_items_attributes][i][:sub_order_amount] = (meal.price * qty)
        total_order_amount += (meal.price * qty)
        i = i + 1
      end
      total_tax = (total_order_amount * restaurant.tax_percent) / 100
      total_order_amount += total_tax + restaurant.delivery_charge +
                            restaurant.packing_charge
      params[:tax_amount] = total_tax
      params[:delivery_charge] = restaurant.delivery_charge
      params[:packing_charge] = restaurant.packing_charge
      params[:total_bill_amount] = total_order_amount
      params
    end
  end
end
