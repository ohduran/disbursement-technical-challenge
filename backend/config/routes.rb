Rails.application.routes.draw do
  resources :disbursements, only: [:index]
end
