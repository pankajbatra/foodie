Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/mgmt', as: 'rails_admin'
  devise_for :users,
             path: '',
             path_names: {
                 sign_in: 'login',
                 sign_out: 'logout'
             },
             controllers: {
                 sessions: 'sessions'
             }
  # scope module: :v1, constraints: ApiVersion.new('v1', true) do
  #   resources :restaurants
  # end

end
