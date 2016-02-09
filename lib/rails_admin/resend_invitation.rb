module RailsAdmin
  module Config
    module Actions
      class ResendInvitation < RailsAdmin::Config::Actions::Base
        # This ensures the action only shows up for Users
        register_instance_option :visible? do
          authorized? && bindings[:object].status == 'invitation-pending'
        end

        register_instance_option :member do
          true
        end
        register_instance_option :link_icon do
          'icon-envelope'
        end

        register_instance_option :pjax? do
          false
        end

        register_instance_option :http_methods do
          [:get]
        end

        register_instance_option :controller do
          proc do
            @object.invite!(current_user)
            redirect_to back_or_index, notice: "Invitation resent to '#{@object.email}'"
          end
        end
      end
    end
  end
end
