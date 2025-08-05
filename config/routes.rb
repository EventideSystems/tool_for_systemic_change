Rails.application.routes.draw do

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :checklist_items, only: %i[show edit update]
  resources :data_models, only: %i[index show edit update] do
    member do
      get 'edit_name'
      patch 'update_name'
      get 'edit_description'
      patch 'update_description'
    end
    resources :goals, only: %i[index new create], controller: 'goals'
    member do
      post 'copy_to_current_workspace'
    end
  end

  resources :impact_cards do
    member do
      get :import_comments
      post :import_comments
    end
    resources :sharing, only: [:index], controller: 'impact_cards/sharing'
    resources :initiatives, only: %i[show new create], controller: 'impact_cards/initiatives'
    resources :stakeholder_network, only: [:index], controller: 'impact_cards/stakeholder_network'
    resources :thematic_map, only: [:index], controller: 'impact_cards/thematic_map'
    resource :merge, only: %i[new create], controller: 'impact_cards/merge'
  end

  resources :goals do
    resources :targets, only: %i[index new create], controller: 'targets'
  end

  resources :indicators

  resources :targets do
    resources :indicators, only: %i[index new create], controller: 'indicators'
  end

  namespace :labels do
    resources :communities
    resources :stakeholder_types
    resources :subsystem_tags
    resources :wicked_problems
  end

  devise_for :users, controllers: {
    invitations: 'invitations'
   }

  resources :workspaces do
    member do
      get 'switch'
    end
  end

  resources :characteristics do
    member do
      get 'description'
    end
  end

  resources :contacts, only: %i[new create] do
    collection do
      get 'privacy'
      get 'terms'
      get 'takedown'
    end
  end

  resources :focus_area_groups
  resources :focus_areas
  resources :initiatives do
    collection do
      get :import
      post :import
    end
    resources :checklist_items do
      member do
        post 'update_comment'
        post 'create_comment'
        get 'comment_status'
      end
    end
    get 'linked'
  end
  
  resources :impact_cards_communities, only: %i[index new create]
  resources :impact_cards_wicked_problems, only: %i[index new create]
  resources :initiatives_subsystem_tags, only: %i[index new create]
  resources :initiatives_organisations, only: %i[index new create]

  resources :organisations do
    collection do
      get :import
      post :import
    end
  end

  resources :shared,
            constraints: {
              id: /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})|(\d+)/
            },
            only: [:show] do
    member do
      get 'stakeholder_network'
      get 'thematic_map'
    end

    resources :characteristics, only: [:show], controller: 'shared', action: 'characteristic'
  end

  resources :users do
    post :stop_impersonating, on: :collection

    post :impersonate, on: :member

    member do
      get 'undelete'
      get 'resend_invitation'
      get 'remove_from_workspace'
    end
  end

  resources :reports, only: [:index] do
    collection do
      post 'initiatives'
      post 'stakeholders'
      get 'scorecard_activity'
      post 'scorecard_activity'
      post 'impact_card_stakeholders'
      post 'scorecard_comments'
      get 'scorecard_comments'
      get 'impact_card_activity'
      post 'impact_card_activity'
      get 'subsystem_summary'
      post 'subsystem_summary'
      get 'cross_workspace_percent_actual'
      post 'cross_workspace_percent_actual'
      get 'cross_workspace_percent_actual_by_focus_area'
      post 'cross_workspace_percent_actual_by_focus_area'
      get 'cross_workspace_percent_actual_by_focus_area_tabbed'
      post 'cross_workspace_percent_actual_by_focus_area_tabbed'
    end
  end

  get 'dashboard', to: 'dashboard#index'
  get 'reports', to: 'reports#index'
  get 'activities', to: 'activities#index'
  get 'privacy', to: 'home#privacy'
  get 'cookie', to: 'home#cookie'
  get 'terms', to: 'home#terms'
  get 'data_retention', to: 'home#data_retention'
  get 'takedown', to: 'home#takedown'

  root to: 'home#index'
end
