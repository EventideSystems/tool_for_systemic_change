# frozen_string_literal: true

class User < ApplicationRecord
  has_paper_trail

  enum system_role: { member: 0, admin: 1 }

  acts_as_paranoid

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts_users
  has_many :accounts, through: :accounts_users
  has_many :active_accounts_with_admin_role,
           lambda {
             where(accounts_users: { account_role: :admin })
               .where('accounts.expires_on IS NULL OR accounts.expires_on >= ?', Date.today)
           },
           through: :accounts_users,
           source: :account

  accepts_nested_attributes_for :accounts_users, allow_destroy: true

  attr_accessor :account_role # Virtual attribute used when inviting users

  def active_for_authentication?
    super && (admin? || default_account.present?)
  end

  def status
    return 'deleted' unless deleted_at.blank?
    return 'invitation-pending' unless invitation_token.blank?

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
