Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  root to: "home#index"

  resources :bookings, only: [:index, :show, :create]
  resources :show_times, only: [:index, :show]

  resources :movies do
    member do
      patch :restore
    end
  end
end
