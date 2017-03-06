class InvitationsController < Devise::InvitationsController
  
  layout 'application', only: [:new] # NOTE Defaults to 'devise' layout for other actions
  
  def update
    super
  end
  
  def create
    binding.pry
    super
  end
  
  def new
    
    super
  end


end