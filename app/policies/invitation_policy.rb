class InvitationPolicy < ApplicationPolicy
  attr_reader :user, :invitation

  def initialize(user, invitation)
    @user = user
    @invitation = invitation
  end

  def create?
    user.staff? or (user.admin? && %w(user admin).include?(invitation.role))
  end
end
