Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Titles (standalone resource)
      resources :titles, only: %i[index show create update] do
        member do
          get :availability, to: "availability#show"
          post :availability, to: "availability#report"
        end
      end

      # Households with nested resources
      resources :households do
        # Recommendations for household
        resources :recommendations, only: [:index]

        # Subscription intelligence
        get :subscription_intelligence, to: "subscriptions#intelligence"

        # Subscriptions
        resources :subscriptions

        # Members with their nested resources
        resources :members do
          # Viewing records
          resources :viewing_records, only: %i[index create update destroy]

          # Data export
          resource :data_export, only: %i[show create]

          # Account deletion
          resource :account_deletion, only: %i[show create]
        end
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
