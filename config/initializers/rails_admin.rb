require Rails.root.join('lib', 'rails_admin', 'invite_user.rb')
RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::InviteUser)

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
      except ['User']
    end
    invite_user do
      only ['User']
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
    exclude_fields :linked
  end

  config.model 'User' do

    object_label_method do
      :displayed_name
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


end
