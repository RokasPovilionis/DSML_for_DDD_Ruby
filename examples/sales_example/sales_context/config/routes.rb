Rails.application.routes.draw do
  # Health check endpoint
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Sales bounded context routes
  namespace :api do
    namespace :v1 do
      namespace :sales do
        resources :orders, only: %i[create show index]
      end
    end
  end
end
