### Monkey pactch for unscoped records in admin panel
require 'rails_admin/main_controller'
module RailsAdmin
  class MainController
    alias_method :old_get_collection, :get_collection
    alias_method :old_get_object, :get_object

    def get_collection(model_config, scope, pagination)
      old_get_collection(model_config, model_config.abstract_model.model.unscoped, pagination)
    end

    def get_object
      raise RailsAdmin::ObjectNotFound unless (object = @abstract_model.model.unscoped.find(params[:id]))
      @object = RailsAdmin::Adapters::ActiveRecord::AbstractObject.new(object)
    end
  end
end
