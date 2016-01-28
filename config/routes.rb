Rails.application.routes.draw do

  UUID_OR_NUMERIC_REGEX = /([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})|(\d+)/

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :activities, :defaults => { :format => 'json' },  only: [:index]
  resources :initiatives, :defaults => { :format => 'json' } do
    resources :checklist_items, :defaults => { :format => 'json' }, controller: 'checklist_items' do
      put 'bulk', on: :collection
    end
  end

  resource :dashboard, :controller => 'dashboard', :defaults => { :format => 'json' }, only: [:show]

  match 'initiatives/:initiative_id/checklist_items', to: 'checklist_items#bulk_update', via: [:put, :patch], :defaults => { :format => 'json' }
  resources :organisations, :defaults => { :format => 'json' }
  resources :clients, :defaults => { :format => 'json' }
  resource :current_client, :controller => 'current_client', :defaults => { :format => 'json' }, only: [:show, :update]
  resources :communities, :defaults => { :format => 'json' }
  resources :invitations, :controller => 'invitations', only: [:create], :defaults => { :format => 'json' }
  resources :scorecards, :defaults => { :format => 'json' }, :constraints => { :id => UUID_OR_NUMERIC_REGEX } do
    resources :initiatives, controller: 'scorecard_initiatives', :defaults => { :format => 'json' }, only: [:index, :show]
  end
  resources :wicked_problems, :defaults => { :format => 'json' }

  resources :focus_area_groups, defaults: { :format => 'json' }, only: [:show, :index]
  resources :focus_areas, defaults: { :format => 'json' }, only: [:show, :index] do
    get 'video_tutorial', on: :member
  end
  resources :characteristics, defaults: { :format => 'json' }, only: [:show, :index] do
    get 'video_tutorial', on: :member
  end

  resources :video_tutorials, defaults: { :format => 'json' }, only: [:show, :index]

  get 'embed', to: 'scorecards#embed'

  devise_for :users, :controllers => { :invitations => 'invitations' }

  # devise_for :users , :skip => 'invitation'
  # devise_scope :user do
  #   get "/users/invitation/accept", :to => "custom_invitations#edit",   :as => 'accept_user_invitation'
  #   put "/invitations/user",    :to => "custom_invitations#update", :as => nil
  # end
  namespace :reports do
    get 'initiatives', defaults: { :format => 'json' }
    get 'stakeholders', defaults: { :format => 'json' }
  end

  resources :users, only: [:show, :index], :defaults => { :format => 'json' }
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Required by Devise
  root to: "dashboard#index"

  get 'profile' => 'profile#show', :defaults => { :format => 'json' }

  apipie

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
