module V1
  class CuisinesController < ApiController
    before_action :authenticate_user!

    def index
      json_response(Cuisine.where(status: Cuisine.status.values[0]).order(name: :asc))
    end
  end
end
