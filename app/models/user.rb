# frozen_string_literal: true
class User < ApplicationRecord
  include Trackable
  
  enum system_role: { member: 0, admin: 1 }

  mount_uploader :profile_picture, ProfilePictureUploader
  acts_as_paranoid
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :accounts_users
  has_many :accounts, through: :accounts_users
  
  accepts_nested_attributes_for :accounts_users, allow_destroy: true
  
  attr_accessor :account_role # Virtual attribute used when inviting users

  def status
    return 'deleted' unless deleted_at.blank?
    return 'invitation-pending' unless invitation_token.blank?
    'active'
  end
  
  def display_name
    name.presence || email
  end 

  # SMELL in use?
  def default_account
    accounts_users.order(account_role: :desc).first.try(:account)
  end
  
  def primary_account_name
    default_account.present? ? default_account.name : '<none>'
  end
end
