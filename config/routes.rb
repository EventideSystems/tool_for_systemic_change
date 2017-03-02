Rails.application.routes.draw do
  
  devise_for :users

  resources :accounts do
    member do
      get 'switch'
    end
  end
  
  resources :characteristics
  
  resources :communities
  resources :focus_area_groups
  resources :focus_areas
  resources :initiatives, except: [:new, :create] do
    resources :checklist_items
  end
  resources :initiatives_organisations
  resources :organisations
  resources :scorecards
  resources :sectors
  resources :users
  resources :video_tutorials
  resources :wicked_problems

  
  get 'dashboard', to: 'dashboard#index'
  get 'reports', to: 'reports#index'
  get 'activities', to: 'activities#index'

  root to: "home#index"
end