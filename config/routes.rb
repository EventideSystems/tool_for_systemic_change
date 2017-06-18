Rails.application.routes.draw do
  
  UUID_OR_NUMERIC_REGEX = /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})|(\d+)/
  
  devise_for :users, skip: [:registrations], :controllers => { :invitations => 'invitations' }

  resources :accounts do
    member do
      get 'switch'
    end
  end
  
  resources :characteristics
  resources :communities
  resources :focus_area_groups
  resources :focus_areas
  resources :initiatives do
    resources :checklist_items
  end
  resources :initiatives_organisations
  resources :organisations
  resources :scorecards do
    member do
      get 'show_shared_link'
    end
  end
  resources :shared, :constraints => { id: UUID_OR_NUMERIC_REGEX }, only: [:show]
  resources :sectors
  resources :users do
    member do
      get 'remove_from_account'
    end
  end
  
  resources :video_tutorials
  resource :welcome_message, only: [:show]
  resources :wicked_problems
  
  resources :reports, only: [:index] do
    collection do
      post 'initiatives'
      post 'stakeholders'
      post 'scorecard_activity'
      get 'scorecard_activity'
    end
  end

  resources :search_results, only: [:index, :show]
  
  get 'dashboard', to: 'dashboard#index'
  get 'reports', to: 'reports#index'
  get 'activities', to: 'activities#index'
  
  namespace :system do
    resources :users do
      member do
        get 'undelete'
        get 'resend_invitation'
      end
    end
  end
  
  root to: "home#index"
end