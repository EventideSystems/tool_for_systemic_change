# frozen_string_literal: true

class WelcomeMessagesController < ApplicationController

  def show
    @welcome_message = current_account.welcome_message
    render(layout: false)
  end
end
