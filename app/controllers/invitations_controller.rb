class InvitationsController < Devise::InvitationsController
  
  layout 'application', only: [:new] # NOTE Defaults to 'devise' layout for other actions
  
  def update
    super
  end
  
  def create
    super
  end
  
  def new
    self.resource = resource_class.new
    authorize self.resource 
    render :new
  end


end