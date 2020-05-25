Rails.application.routes.draw do
  root to: 'converter#index'
  resources :converter, only: %w[index create]
end
