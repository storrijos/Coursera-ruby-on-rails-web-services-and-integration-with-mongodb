Rails.application.routes.draw do
  root 'places#index'
  resources :places, only: [:index, :show]
  get 'photos/:id/show', to:'photos#show', as: 'photos_show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
