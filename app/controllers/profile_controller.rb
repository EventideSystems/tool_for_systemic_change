class ProfileController < ApplicationController

  # GET /profile
  # GET /profile.json
  def show
    @profile = Profile.new(current_user)
    render json: @profile
  end

end
