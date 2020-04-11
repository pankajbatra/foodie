module V1
  class MealsController < ApiController
    before_action :authenticate_user!
    before_action :meal_params

    def index
      if current_user.is_restaurant_owner?
        if current_user.restaurant == nil || current_user.restaurant.status != Restaurant.status.values[0]
          json_response({message: 'Record not found'}, :not_found)
        else
          json_response(current_user.restaurant.meals)
        end
      else
        restaurant = Restaurant.find_by_rid(params[:rid])
        if restaurant == nil || restaurant.status !=Restaurant.status.values[0]
          json_response({message: 'Record not found'}, :not_found)
        else
          json_response(restaurant.meals.where.not(status: Meal.status.values[1]))
        end
      end
    end

    def create
      if current_user.is_restaurant_owner? && current_user.restaurant != nil &&
          current_user.restaurant.status == Restaurant.status.values[0]
        meal = Meal.create!(meal_params.merge(:restaurant_id => current_user.restaurant.id))
        json_response(meal, :created)
      else
        json_response({message: 'You don\'t have permission for this operation'}, 403)
      end
    end

    def update
      if current_user.is_restaurant_owner? && current_user.restaurant != nil &&
          current_user.restaurant.status == Restaurant.status.values[0]
        meal = Meal.find_by_id(params[:id])
        if meal == nil || meal.restaurant.id != current_user.restaurant.id
          json_response({message: 'Record not found'}, :not_found)
        else
          if request.method == 'PATCH'
            meal.update!({status: params[:status]})
            head :no_content
          else
            meal.update!(meal_params)
            head :no_content
          end
        end
      else
        json_response({message: 'You don\'t have permission for this operation'}, 403)
      end
    end

    private
    def meal_params
      params.permit(:rid, :name, :cuisine_id, :description, :is_chef_special, :is_veg, :contains_egg,
                    :contains_meat, :is_vegan, :is_halal, :course, :ingredients, :spice_level,
                    :price, :serves, :id, :status)
    end
  end
end
