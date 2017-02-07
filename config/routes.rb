Rails.application.routes.draw do
  resources :organisations
  resources :initiatives
  resources :initiatives_organisations
  resources :checklist_items
  resources :scorecards
  resources :wicked_problems
  resources :communities
  resources :video_tutorials
  resources :characteristics
  resources :focus_areas
  resources :focus_area_groups
  resources :accounts
  resources :sectors
  devise_for :users
  resources :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: "home#index"
  
  get 'dashboard', to: 'dashboard#index'
  get 'reports', to: 'reports#index'
  get 'activities', to: 'activities#index'
end
