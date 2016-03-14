require Rails.root.join('lib', 'rails_admin', 'invite_user.rb')
require Rails.root.join('lib', 'rails_admin', 'resend_invitation.rb')
require Rails.root.join('lib', 'rails_admin', 'new_client.rb')
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::InviteUser)
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::ResendInvitation)
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::NewClient)

RailsAdmin.config do |config|

  config.main_app_name = ["Wicked Lab", "Back Office"]
  ### Popular gems integration

  # == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)


  config.authorize_with :pundit do
    redirect_to main_app.root_path unless current_user.staff?
  end

  config.current_user_method(&:current_user)
  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      except ['User', 'Client']
    end
    invite_user do
      only ['User']
    end
    resend_invitation do
      only ['User']
    end
    new_client do
      only ["Client"]
    end
    export
    bulk_delete
    show
    edit
    delete

    ## With an audit adapter, you can add:
    # history_index
    # history_show

  end

  config.model 'FocusArea' do
    parent FocusAreaGroup
  end

  config.model 'Characteristic' do
    parent FocusArea
  end

  config.model 'VideoTutorial' do

    list do
      field :name
      field :description
      field :promote_to_dashboard do
        label "Promoted"
      end
      field :position
      field :link_url do
        label "Vimeo Link URL"
      end
      field :linked do
        label "Focus Area / Characteristic"
      end
    end

    show do
      field :name
      field :description
      field :promote_to_dashboard do
        label "Promoted"
      end
      field :position
      field :link_url do
        label "Vimeo Link URL"
      end
      field :linked do
        label "Focus Area / Characteristic"
      end
      field :created_at
      field :updated_at
    end

    edit do
      field :name
      field :description
      field :promote_to_dashboard
      field :position do
        help "Only applies to promoted videos"
      end
      field :link_url do
        required true
        label "Vimeo Link URL"
      end
      exclude_fields :linked
    end
  end

  config.model 'User' do

    object_label_method do
      :displayed_name
    end

    list do
      field :name
      field :email
      field :role
      field :client
      field :status, :string
    end

    show do
      field :name
      field :email
      field :role
      field :client
      field :status, :string
      field :created_at
      field :updated_at
      field :invited_by
      field :sign_in_count
      field :current_sign_in_at
      field :last_sign_in_at
    end

    edit do
      field :email do
        required true
      end
      field :name
      field :role do
        required true
      end
      field :client do
        help "Required unless role is 'Staff'"
      end
    end
  end

  config.model 'Client' do
    list do
      field :name
      field :description
      field :weblink
      field :sector
    end

    edit do
      field :name do
        required true
      end
      field :description
      field :weblink
      field :sector
      field :welcome_message
    end

    create do
      field :name do
        required true
      end
      field :description
      field :weblink
      field :sector
      field :welcome_message
      field :initial_admin_user_email
      field :initial_admin_user_name
    end
  end
end
