# frozen_string_literal: true
class User < ApplicationRecord
  enum system_role: { member: 0, admin: 1 }

  mount_uploader :profile_picture, ProfilePictureUploader
  acts_as_paranoid

  include Trackable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts_users
  has_many :accounts, through: :accounts_users

  def status
    return 'deleted' unless deleted_at.blank?
    return 'invitation-pending' unless invitation_token.blank?
    'active'
  end

  def default_account
    accounts_users.order(account_role: :desc).first.try(:account)
  end
end
