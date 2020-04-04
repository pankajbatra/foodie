module V1
  class OrdersController < ApiController
    before_action :authenticate_user!
    before_action :set_order, only: [:show, :update]
    before_action :show_params, only: [:show]
    before_action :create_params, only: [:create]
    before_action :index_params, only: [:index]
    before_action :update_params, only: [:update]

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
      restaurant = Restaurant.find_by_rid(params[:rid])
      if current_user.is_customer? && current_user.status == User.status.values[0] &&
          restaurant != nil && restaurant.status == Restaurant.status.values[0] && !current_user.is_blacklisted(restaurant.id)
        order = Order.create!(create_params.except(:rid).merge(:user_id => current_user.id,
                                                 :restaurant_id => restaurant.id, :placed_at =>Time.now))
        json_response(order, :created)
      else
        json_response({ message: 'You don\'t have permission for this operation'}, 403)
      end
    end

    def update
      if @order == nil
        json_response({ message: 'Record not found' }, :not_found)
      elsif params[:status] == nil || params[:status] == Order.status.values[0]
        json_response({ message: 'You don\'t have permission for this operation: Placed'}, 403)
      else
        if current_user.is_restaurant_owner?
          if current_user.restaurant!=nil && current_user.restaurant.status == Restaurant.status.values[0] &&
              current_user.restaurant.id == @order.restaurant_id

            case params[:status]

              # Cancelled status sent
              when Order.status.values[5]
                if @order.status == Order.status.values[5] || @order.status == Order.status.values[4] ||
                    @order.status == Order.status.values[3]
                  json_response({ message: 'You don\'t have permission for this operation: Cancelled'}, 403)
                else

                  # No cancellation reason provided or customerCancel reason provided
                  if params[:cancel_reason] == nil || params[:cancel_reason] == Order.cancel_reason.values[0]
                    json_response({ message: 'No/Invalid Cancellation reason provided'}, 403)

                  # order is in placed or processing, so can't send cancel reason as damaged in transit or undelivered
                  elsif (@order.status == Order.status.values[0] || @order.status == Order.status.values[1]) &&
                      (params[:cancel_reason] == Order.cancel_reason.values[7] ||
                          params[:cancel_reason] == Order.cancel_reason.values[8])
                    json_response({ message: 'Invalid cancellation reason'}, 403)

                  # order is not in placed, so can't send cancel reason as store closed
                  elsif @order.status != Order.status.values[0] && params[:cancel_reason] == Order.cancel_reason.values[2]
                    json_response({ message: 'Invalid cancellation reason: StoreClosed'}, 403)

                  # order is in route, so can't send cancel reason as out of stock, store closed or delivery person not available
                  elsif @order.status == Order.status.values[2] &&
                      (params[:cancel_reason] == Order.cancel_reason.values[1] ||
                          params[:cancel_reason] == Order.cancel_reason.values[2] ||
                          params[:cancel_reason] == Order.cancel_reason.values[3])
                    json_response({ message: 'Invalid cancellation reason at this stage'}, 403)

                  else
                    @order.update!({cancel_reason: params[:cancel_reason], remarks: params[:remarks],
                                    :cancelled_at =>Time.now, :status => params[:status]})
                    head :no_content
                  end
                end

              # Processing or Confirmed
              when Order.status.values[1]
                # previous status is not placed
                if @order.status != Order.status.values[0]
                  json_response({ message: 'You don\'t have permission for this operation : Processing'}, 403)
                else
                  @order.update!({bill_number: params[:bill_number],
                                  remarks: params[:remarks], eta_after_confirm: params[:eta_after_confirm],
                                  payment_status: params[:payment_status],
                                  :confirmed_at =>Time.now, :status => params[:status]})
                  head :no_content
                end

              # In Route or Dispatched
              when Order.status.values[2]
                # previous status is not processing
                if @order.status != Order.status.values[1]
                  json_response({ message: 'You don\'t have permission for this operation: InRoute'}, 403)
                else
                  @order.update!({bill_number: params[:bill_number],
                                  remarks: params[:remarks],
                                  payment_status: params[:payment_status],
                                  :dispatched_at =>Time.now, :status => params[:status]})
                  head :no_content
                end

              # Delivered
              when Order.status.values[3]
                # previous status is not inRoute
                if @order.status != Order.status.values[2]
                  json_response({ message: 'You don\'t have permission for this operation: Delivered'}, 403)
                else
                  @order.update!({remarks: params[:remarks],
                                  payment_status: params[:payment_status],
                                  :delivered_at =>Time.now, :status => params[:status]})
                  head :no_content
                end
              else
                json_response({ message: 'You don\'t have permission for this operation: Invalid'}, 403)
            end
          else
            json_response({ message: 'You don\'t have permission for this operation'}, 403)
          end
        else
          if current_user.id == @order.user_id
            # Cancelled
            if params[:status] == Order.status.values[5]
              # previous status is not Placed
              if @order.status != Order.status.values[0]
                json_response({ message: 'You don\'t have permission for this operation'}, 403)
              else
                @order.update!({cancel_reason: Order.cancel_reason.values[0],
                                :cancelled_at =>Time.now, :status => params[:status]})
                head :no_content
              end
            # Received
            elsif params[:status] == Order.status.values[4]
              # previous status is not delivered yet
              if @order.status != Order.status.values[3]
                json_response({ message: 'You don\'t have permission for this operation'}, 403)
              else
                @order.update!({:received_at =>Time.now, :status => params[:status]})
                head :no_content
              end
            else
              json_response({ message: 'You don\'t have permission for this operation'}, 403)
            end
          else
            json_response({ message: 'You don\'t have permission for this operation'}, 403)
          end
        end
      end
    end

    private
    def index_params
      params.permit(:page)
    end

    def create_params
      params.permit(:rid, :tax_amount, :delivery_charge, :packing_charge, :total_bill_amount, :payment_mode,
                    :special_request, :customer_mobile, :customer_address, :customer_locality, :customer_latitude,
                    :customer_longitude, :customer_name,
                    order_items_attributes: [:meal_id, :quantity, :meal_name, :price_per_item, :sub_order_amount])
    end

    def update_params
      params.permit(:oid, :status, :cancel_reason, :remarks, :bill_number, :payment_status, :eta_after_confirm,
                    :payment_status)
    end

    def show_params
      params.permit(:oid)
    end

    def set_order
      @order = Order.find_by_oid(params[:oid])
    end
  end
end
