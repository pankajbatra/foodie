module V1
  class RestaurantsController < ApiController
    before_action :authenticate_user!
    before_action :set_restaurant, only: [:show, :update]

    def index
      if current_user.is_restaurant_owner?
        if current_user.restaurant ==nil
          json_response({ message: 'Record not found' }, :not_found)
        else
          json_response(current_user.restaurant)
        end
      else
        @restaurants = Restaurant.where(status:Restaurant.status.values[0]).paginate(page: params[:page], per_page: 20)
        json_response(@restaurants)
      end
    end

    # POST /restaurants
    def create
      if current_user.is_restaurant_owner? && current_user.restaurant==nil
        @restaurant = Restaurant.create!(restaurant_params.merge(:owner_id => current_user.id))
        json_response(@restaurant, :created)
      else
        json_response({ message: 'You don\'t have permission for this operation'}, 403)
      end
    end

    # GET /restaurants/:rid
    def show
      if @restaurant ==nil
        json_response({ message: 'Record not found' }, :not_found)
      else
        if current_user.is_restaurant_owner?
          if current_user.restaurant!=nil && current_user.restaurant.rid == @restaurant.rid
            json_response(@restaurant)
          else
            json_response({ message: 'You don\'t have permission for this operation'}, 403)
          end
        else
            json_response(@restaurant)
        end
      end
    end

    # t.decimal 'rating', precision: 5, scale: 4

    # PUT /restaurants/:rid
    # PATCH /restaurants/:rid
    def update
      if @restaurant ==nil
        json_response({ message: 'Record not found' }, :not_found)
      else
        if current_user.is_restaurant_owner?
          if current_user.restaurant!=nil && current_user.restaurant.rid == @restaurant.rid
            if request.method == 'PATCH'
              @restaurant.update!({open_for_delivery_now: params[:open_for_delivery_now]})
              head :no_content
            else
              @restaurant.update!(restaurant_params)
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

    private
    def restaurant_params
      params.permit(:rid, :name, :description, :min_delivery_amount, :avg_delivery_time, :delivery_charge,
      :packing_charge, :tax_percent, :phone_number, :locality, :address, :latitude, :longitude, :open_for_delivery_now,
      cuisine_ids: [])
    end

    def set_restaurant
      @restaurant = Restaurant.find_by_rid(params[:rid])
    end
  end
end
