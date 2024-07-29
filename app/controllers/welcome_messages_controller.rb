# frozen_string_literal: true

class WelcomeMessagesController < ApplicationController
  skip_after_action :verify_policy_scoped
  skip_after_action :verify_authorized

  def show
    @welcome_message = current_account.welcome_message
    render(layout: false)
  end
end
