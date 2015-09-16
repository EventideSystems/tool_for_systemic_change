class InvitationsController < Devise::InvitationsController

  before_filter :configure_permitted_parameters

  def create
    # SMELL Hack!
    if self.params[:user][:client_id].nil?
      self.params[:user].merge!(
        client_id: current_user.client_id
      )
    end

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

    # if resource_invited
    #   if is_flashing_format? && self.resource.invitation_sent_at
    #     set_flash_message :notice, :send_instructions, :email => self.resource.email
    #   end
    #   respond_with resource, :location => after_invite_path_for(current_inviter)
    # else
    #   respond_with_navigational(resource) { render :new }
    # end
  end

  private

    def client_id_from_params(params)
      self.params[:user][:client_id].to_i
    rescue
      nil
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:invite) do |u|
        u.permit(:email, :client_id, :role)
      end
    end
end
