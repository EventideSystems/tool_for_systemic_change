Rails.application.routes.draw do
  resources :subsystem_tags
  namespace :initiatives do
    resources :imports, only: %i[new create update]
  end

  resources :checklist_items, only: %i[show edit update]

  namespace :organisations do
    resources :imports, only: %i[new create update]
  end

  namespace :transition_card_comments do
    resources :imports, only: %i[new create update], controller: '/scorecard_comments/imports'
  end

  # TODO: Fix this route once we have a proper transition_card_comments import
  namespace :sustainable_development_goal_alignment_card_comments do
    resources :imports, only: %i[new create update], controller: '/scorecard_comments/imports'
  end

  devise_for :users, skip: [:registrations], controllers: { invitations: 'invitations' }

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
    get 'linked'
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
      get 'linked_initiatives/:target_id', action: 'linked_initiatives', as: 'linked_initiatives'
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
      get 'linked_initiatives/:target_id', action: 'linked_initiatives', as: 'linked_initiatives'
    end

    resources :characteristics,
              only: [:show],
              controller: 'sustainable_development_goal_alignment_cards',
              action: 'characteristic'
  end

  resources :ecosystem_maps do
    resources :organisations, only: [:show], controller: 'ecosystem_maps/organisations'
  end

  resources :shared,
            constraints: {
              id: /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})|(\d+)/
            },
            only: [:show] do
    member do
      get 'targets_network_map'
    end

    resources :characteristics, only: [:show], controller: 'shared', action: 'characteristic'
  end

  resources :stakeholder_types
  resources :users do
    post :stop_impersonating, on: :collection

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
      get 'subsystem_summary'
      post 'subsystem_summary'
      get 'cross_account_percent_actual'
      post 'cross_account_percent_actual'
      get 'cross_account_percent_actual_by_focus_area'
      post 'cross_account_percent_actual_by_focus_area'
      get 'cross_account_percent_actual_by_focus_area_tabbed'
      post 'cross_account_percent_actual_by_focus_area_tabbed'
    end
  end

  resources :search_results, only: %i[index show]

  get 'dashboard', to: 'dashboard#index'
  get 'reports', to: 'reports#index'
  get 'activities', to: 'activities#index'
  get 'contributors', to: 'home#contributors'

  namespace :system do
    resources :stakeholder_types
    resources :users do
      post :impersonate, on: :member

      member do
        get 'undelete'
        get 'resend_invitation'
      end
    end
  end

  root to: 'home#index'
end
