module Trackable
  extend ActiveSupport::Concern

  included do
    include PublicActivity::Model

    tracked owner: Proc.new{ |controller, model|
      controller ? controller.current_user : nil
    }

    tracked account_id: Proc.new{ |controller, model|
      if controller
        controller.current_account ? controller.current_account.id : nil
      else
        nil
      end
    }
  end

end
