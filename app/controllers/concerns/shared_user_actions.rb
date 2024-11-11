# frozen_string_literal: true

module SharedUserActions
  extend ActiveSupport::Concern

  def undelete
    @user.restore
    respond_to do |format|
      format.html { redirect_to system_users_url, notice: 'User was successfully undeleted.' }
      format.json { head :no_content }
    end
  end

  def resend_invitation
    @user.invite!(current_user)

    respond_to do |format|
      format.html { redirect_to system_users_url, notice: 'User was resent invitation.' }
      format.json { head :no_content }
    end
  end
end
