module Trackable
  extend ActiveSupport::Concern

  included do
    include PublicActivity::Model

    tracked owner: Proc.new{ |controller, model|
      controller ? controller.current_user : nil
    }

    tracked client_id: Proc.new{ |controller, model|
      if controller
        controller.current_user ? controller.current_client_id : nil
      else
        nil
      end
    }
  end

end
