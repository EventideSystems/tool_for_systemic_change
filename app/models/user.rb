# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  name                   :string
#  profile_picture        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  system_role            :integer          default("member")
#  time_zone              :string           default("Adelaide")
#  created_at             :datetime
#  updated_at             :datetime
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE WHERE (deleted_at IS NULL)
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_name                  (name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_system_role           (system_role)
#
class User < ApplicationRecord
  include Searchable

  has_paper_trail

  enum :system_role, %i[member admin], default: :member # rubocop:disable Rails/EnumHash

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :workspaces_users, dependent: :destroy
  has_many :workspaces, through: :workspaces_users

  has_many :active_workspaces,
           lambda {
             where('workspaces.expires_on IS NULL OR workspaces.expires_on >= ?', Time.zone.today)
           },
           through: :workspaces_users,
           source: :workspace

  has_many :active_workspaces_with_admin_role,
           lambda {
             where(workspaces_users: { workspace_role: :admin })
               .where('workspaces.expires_on IS NULL OR workspaces.expires_on >= ?', Time.zone.today)
           },
           through: :workspaces_users,
           source: :workspace

  accepts_nested_attributes_for :workspaces_users, allow_destroy: true

  # Virtual attributes used when inviting or updating users
  attr_accessor :initial_workspace_role, :initial_system_role, :workspace_role

  def self.ransackable_attributes(_auth_object = nil)
    %w[name email] + _ransackers.keys
  end

  # Used by Devise to determine if the user is active and can sign in.
  def active_for_authentication?
    super && (admin? || default_workspace.present?)
  end

  # TODO: Consider converting this to symbols.
  def status
    return 'deleted' if deleted_at.present?
    return 'invitation-pending' if invitation_token.present?

    'active'
  end

  # Returns the user's display name, which is their name if present, otherwise their email.
  # TODO: Consider stripping out the email domain and only showing the username.
  def display_name
    name.presence || email
  end

  def default_workspace
    active_workspaces.first || workspaces.first
  end

  def primary_workspace_name
    default_workspace.present? ? default_workspace.name : '<none>'
  end
end
