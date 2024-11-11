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

  enum system_role: { member: 0, admin: 1 }

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts_users, dependent: :destroy
  has_many :accounts, through: :accounts_users
  has_many :active_accounts_with_admin_role,
           lambda {
             where(accounts_users: { account_role: :admin })
               .where('accounts.expires_on IS NULL OR accounts.expires_on >= ?', Time.zone.today)
           },
           through: :accounts_users,
           source: :account

  accepts_nested_attributes_for :accounts_users, allow_destroy: true

  attr_accessor :account_role # Virtual attribute used when inviting users

  def self.ransackable_attributes(_auth_object = nil)
    %w[name email] + _ransackers.keys
  end

  def active_for_authentication?
    super && (admin? || default_account.present?)
  end

  def status
    return 'deleted' if deleted_at.present?
    return 'invitation-pending' if invitation_token.present?

    'active'
  end

  def active_accounts
    user_context = UserContext.new(self, nil)
    AccountPolicy::Scope.new(user_context, Account).resolve
  end

  def display_name
    name.presence || email
  end

  def default_account
    active_accounts.first
  end

  def primary_account_name
    default_account.present? ? default_account.name : '<none>'
  end
end
