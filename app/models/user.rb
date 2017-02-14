class User < ApplicationRecord
  
  enum system_role: [ :member, :admin ]
  
  mount_uploader :profile_picture, ProfilePictureUploader
  acts_as_paranoid

  include Trackable
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  def status
   return 'deleted' unless deleted_at.blank?
   return 'invitation-pending' unless invitation_token.blank?
   return 'active'
  end
end
