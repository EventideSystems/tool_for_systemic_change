class InvitationsController < Devise::InvitationsController

  before_filter :configure_permitted_parameters
  before_filter :set_default_role_param, only: :create
  before_filter :set_default_client_id, only: :create

  resource_description do
    formats ['json']
  end

  def create
    invitation = Invitation.new(
      params[:user][:client_id],
      params[:user][:email],
      params[:user][:role]
    )

    authorize invitation, :create?

    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    respond_to do |format|
      if resource_invited
        format.html { redirect_to resource, notice: 'User was successfully invited.' }
        format.json { render json: resource, status: :created, location: resource }
      else
        format.html { render :new }
        format.json { render json: resource.errors, status: :unprocessable_entity }
      end
    end

  end


  def update
    raw_invitation_token = update_resource_params[:invitation_token]
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      if Devise.allow_insecure_sign_in_after_accept
        flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
        set_flash_message :notice, flash_message if is_flashing_format?
        sign_in(resource_name, resource)
        respond_with resource, :location => after_accept_path_for(resource)
      else
        set_flash_message :notice, :updated_not_active if is_flashing_format?
        respond_with resource, :location => new_session_path(resource_name)
      end
    else
      resource.invitation_token = raw_invitation_token
      respond_with_navigational(resource){ render :edit }
    end
  end


  private

    def client_id_from_params(params)
      self.params[:user][:client_id].to_i
    rescue
      nil
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:invite) do |u|
        u.permit(:email, :client_id, :role, :name)
      end
    end

    def set_default_role_param
      params[:user][:role] = 'user' unless params[:user][:role]
    end

    def set_default_client_id
      params[:user][:client_id] = current_user.client_id unless params[:user][:client_id] || params[:user][:role] == 'staff'
    end

end
