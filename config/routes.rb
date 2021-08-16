Rails.application.routes.draw do
  
  resources :subsystem_tags
  namespace :initiatives do
    resources :imports, only: [:new, :create, :update]
  end
  namespace :organisations do
    resources :imports, only: [:new, :create, :update]
  end
  
  namespace :transition_card_comments do
    resources :imports, only: [:new, :create, :update], controller: '/scorecard_comments/imports'
  end

  UUID_OR_NUMERIC_REGEX = /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})|(\d+)/
  
  devise_for :users, skip: [:registrations], :controllers => { :invitations => 'invitations' }

  resources :accounts do
    member do
      get 'switch'
    end
  end
  
  resources :characteristics do
    member do
      get 'description'
    end
  end
  
  resources :communities
  resources :focus_area_groups
  resources :focus_areas
  resources :initiatives do
    resources :checklist_items do
      member do
        post 'update_comment'
        post 'create_comment'
      end
    end
  end
  resources :initiatives_organisations
  resources :initiatives_subsystem_tags
  resources :networks
  resources :organisations

  resources :transition_cards do
    member do
      get 'show_shared_link'
      post 'copy'
      get 'copy_options'
      post 'merge'
      get 'merge_options'
      get 'ecosystem_maps_organisations'
      get 'ecosystem_maps_initiatives'
    end
  end

  resources :ecosystem_maps do
    resources :organisations, only: [:show], controller: 'ecosystem_maps/organisations'
    resources :initiatives, only: [:show], controller: 'ecosystem_maps/initiatives'
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
      post 'transition_card_stakeholders'
      get 'scorecard_activity'
      post 'scorecard_comments'
      get 'scorecard_comments'
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
