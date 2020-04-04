Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/mgmt', as: 'rails_admin'
  devise_for :users,
             defaults: { format: :json },
             path: '',
             path_names: {
                 sign_in: 'login',
                 sign_out: 'logout',
                 registration: 'signup'
             },
             controllers: {
                 sessions: 'sessions',
                 registrations: 'registrations'
             }
  scope module: :v1, constraints: ApiVersion.new('v1', true) do
    resources :restaurants
    resources :cuisines
    resources :meals
    resources :orders
    patch 'blacklist' => 'restaurants#blacklist', :as => :blacklist
  end
end
