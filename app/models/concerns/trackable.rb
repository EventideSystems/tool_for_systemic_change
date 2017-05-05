# frozen_string_literal: true
require 'public_activity'

module Trackable
  extend ActiveSupport::Concern

  included do

    include PublicActivity::Model

    tracked owner: proc { |controller, _model|
      controller ? controller.current_user : nil
    }

    tracked account_id: proc { |controller, _model|
      if controller
        controller.current_account ? controller.current_account.id : nil
      end
    }
  end
end