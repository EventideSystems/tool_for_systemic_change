class ProfileController < ApplicationController

  resource_description do
    formats ['json']
  end

  # GET /profile
  # GET /profile.json
  def show
    @profile = Profile.new(current_user)
    render json: @profile
  end

end
