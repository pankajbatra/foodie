module V1
  class OrdersController < ApiController
    before_action :authenticate_user!
    before_action :set_order, only: [:show, :update]
    before_action :order_params

    def index
      if current_user.is_restaurant_owner?
        if current_user.restaurant == nil || current_user.restaurant.status != Restaurant.status.values[0]
          json_response({ message: 'Record not found' }, :not_found)
        else
          orders = current_user.restaurant.orders.order(created_at: :desc).paginate(page: params[:page],
                                                                                     per_page: 20)
          json_response(orders)
        end
      else
        orders = current_user.orders.order(created_at: :desc).paginate(page: params[:page],
                                                                                  per_page: 20)
        json_response(orders)
      end
    end

    def show
      if @order == nil
        json_response({ message: 'Record not found' }, :not_found)
      else
        if current_user.is_restaurant_owner?
          if current_user.restaurant!=nil && current_user.restaurant.status == Restaurant.status.values[0] &&
              current_user.restaurant.id == @order.restaurant_id
            json_response(@order)
          else
            json_response({ message: 'You don\'t have permission for this operation'}, 403)
          end
        else
          if current_user.id == @order.user_id
            json_response(@order)
          else
            json_response({ message: 'You don\'t have permission for this operation'}, 403)
          end
        end
      end
    end

    def create
      # not blocked for this restaurant
      # todo
      restaurant = Restaurant.find_by_rid(params[:rid])
      if current_user.is_customer? && current_user.status == User.status.values[0] &&
          restaurant != nil && restaurant.status == Restaurant.status.values[0]
        order = Order.create!(order_params.except(:rid).merge(:user_id => current_user.id,
                                                 :restaurant_id => restaurant.id, :placed_at =>Time.now))
        json_response(order, :created)
      else
        json_response({ message: 'You don\'t have permission for this operation'}, 403)
      end
    end

    # def update
    # end

    private
    def order_params
      params.permit(:oid, :rid, :tax_amount, :delivery_charge, :packing_charge, :total_bill_amount, :payment_mode,
                    :special_request, :customer_mobile, :customer_address, :customer_locality, :customer_latitude, :customer_longitude,
                    :customer_name, :page,
                    order_items_attributes: [:meal_id, :quantity, :meal_name, :price_per_item, :sub_order_amount])
    end

    def set_order
      @order = Order.find_by_oid(params[:oid])
    end
  end
end
