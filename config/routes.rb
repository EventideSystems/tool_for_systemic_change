Rails.application.routes.draw do

  resources :subsystem_tags
  namespace :initiatives do
    resources :imports, only: [:new, :create, :update]
    resources :checklist_items, only: [:edit], controller: '/initiatives', action: 'edit_checklist_item'
  end
  namespace :organisations do
    resources :imports, only: [:new, :create, :update]
  end

  namespace :transition_card_comments do
    resources :imports, only: [:new, :create, :update], controller: '/scorecard_comments/imports'
  end

  # TODO: Fix this route once we have a proper transition_card_comments import
  namespace :sustainable_development_goal_alignment_card_comments do
    resources :imports, only: [:new, :create, :update], controller: '/scorecard_comments/imports'
  end

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
        get 'comment_status'
      end
    end
  end
  resources :initiatives_organisations
  resources :initiatives_subsystem_tags
  resources :organisations

  resources :transition_cards do
    member do
      get 'show_shared_link'
      post 'copy'
      get 'copy_options'
      post 'merge'
      get 'merge_options'
      get 'ecosystem_maps_organisations'
      get 'activities'
    end
  end

  resources :sustainable_development_goal_alignment_cards do
    member do
      get 'show_shared_link'
      post 'copy'
      get 'copy_options'
      post 'merge'
      get 'merge_options'
      get 'ecosystem_maps_organisations'
      get 'activities'
      get 'targets_network_map'
    end
  end

  resources :ecosystem_maps do
    resources :organisations, only: [:show], controller: 'ecosystem_maps/organisations'
  end

  resources :shared, constraints: {
    id: /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})|(\d+)/
  }, only: [:show]

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
      get 'scorecard_activity'
      post 'scorecard_activity'
      post 'transition_card_stakeholders'
      post 'scorecard_comments'
      get 'scorecard_comments'
      get 'transition_card_activity'
      post 'transition_card_activity'
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
