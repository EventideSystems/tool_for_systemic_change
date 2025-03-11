# frozen_string_literal: true

# Controller for the contacts page
class ContactsController < ApplicationController
  skip_before_action :authenticate_user!

  layout 'home'

  def new
    @contact = Contact.new
  end

  def privacy
    @contact = Contact.new
  end

  def terms
    @contact = Contact.new
  end

  def create # rubocop:disable Metrics/MethodLength
    @contact = Contact.new(params[:contact].permit(:name, :email, :message))
    recaptcha_valid = verify_recaptcha(model: @contact, action: 'contact')
    if recaptcha_valid
      if @contact.save
        ContactMailer.contact(@contact.name, @contact.email, @contact.message).deliver_now
        redirect_to root_path, notice: 'Your message has been sent.'
      else
        render 'new'
      end
    else
      # Score is below threshold, so user may be a bot. Show a challenge, require multi-factor
      # authentication, or do something else.
      render 'new'
    end
  end
end
