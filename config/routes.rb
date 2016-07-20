Rails.application.routes.draw do
  root to: 'top#index'

  devise_for :users
  resources :rooms do
    resources :bookings
  end

  get '.well-known/acme-challenge/:id', to: "top#letsencrypt"

  get 'oauth2callback', to: "googles#callback"
  get 'google_authorize', to: "googles#authorize"
end
