module RailsAdmin
  module Config
    module Actions
      class InviteUser < RailsAdmin::Config::Actions::Base
        # This ensures the action only shows up for Users
        register_instance_option :visible? do
          authorized? && bindings[:abstract_model].model_name == 'User'
        end

        register_instance_option :collection do
          true
        end
        register_instance_option :link_icon do
          'icon-plus'
        end

        register_instance_option :pjax? do
          false
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          proc do
            if request.get? # NEW

              @object = @abstract_model.new
              @authorization_adapter && @authorization_adapter.attributes_for(:invite_user, @abstract_model).each do |name, value|
                @object.send("#{name}=", value)
              end
              if object_params = params[@abstract_model.to_param]
                @object.set_attributes(@object.attributes.merge(object_params))
              end
              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.post? # CREATE

              @modified_assoc = []
              @object = @abstract_model.new
              sanitize_params_for!(request.xhr? ? :modal : :create)

              @object.set_attributes(params[@abstract_model.param_key])
              @authorization_adapter && @authorization_adapter.attributes_for(:invite_user, @abstract_model).each do |name, value|
                @object.send("#{name}=", value)
              end

              @object.invite!(current_user)
              invitation_accepted = @object.errors.empty?

              if invitation_accepted
                @auditing_adapter && @auditing_adapter.create_object(@object, @abstract_model, _current_user)
                respond_to do |format|
                  format.html { redirect_to invite_user_path }
                  format.js   { render json: {id: @object.id.to_s, label: @model_config.with(object: @object).object_label} }
                end
              else
                handle_save_error
              end
            end
          end
        end
      end
    end
  end
end
