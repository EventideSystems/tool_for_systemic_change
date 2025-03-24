# frozen_string_literal: true

# Holds the user and workspace context for the current request
class UserContext
  attr_reader :user, :workspace

  def initialize(user, workspace)
    @user = user
    @workspace = workspace
  end
end
