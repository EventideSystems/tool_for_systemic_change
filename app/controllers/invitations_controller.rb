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
