module V1
  class RestaurantsController < ApiController
    before_action :authenticate_user!
    before_action :set_restaurant, only: [:show, :update]

    def index
      if current_user.is_restaurant_owner?
        json_response(current_user.restaurant)
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
      if current_user.is_restaurant_owner?
        if current_user.restaurant!=nil && current_user.restaurant.rid == params[:rid]
          json_response(current_user.restaurant)
        else
          json_response({ message: 'You don\'t have permission for this operation'}, 403)
        end
      else
        json_response(@restaurant)
      end
    end

    # t.decimal 'rating', precision: 5, scale: 4

    # PUT /restaurants/:rid
    # PATCH /restaurants/:rid
    def update
      if current_user.is_restaurant_owner?
        if current_user.restaurant!=nil && current_user.restaurant.rid == params[:rid]
          if request.method == 'PATCH'
            current_user.restaurant.update({open_for_delivery_now: params[:open_for_delivery_now]})
            head :no_content
          else
            current_user.restaurant.update(restaurant_params)
            head :no_content
          end
        else
          json_response({ message: 'You don\'t have permission for this operation'}, 403)
        end
      else
        json_response({ message: 'You don\'t have permission for this operation'}, 403)
      end
    end

    private
    def restaurant_params
      params.permit(:name, :description, :min_delivery_amount, :avg_delivery_time, :delivery_charge,
      :packing_charge, :tax_percent, :phone_number, :locality, :address, :latitude, :longitude, :open_for_delivery_now)
    end

    def set_restaurant
      @restaurant = Restaurant.find_by_rid(params[:rid])
    end
  end
end
