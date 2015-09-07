class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :administrating_organisation, class_name: 'AdministratingOrganisation'

  enum role: [ :user, :admin, :staff ]

  validates :administrating_organisation_id, presence: true,
    unless: Proc.new { |u| u.staff? }

  scope :for_user, ->(user) {
    if user.user?
      where(id: user.id)
    elsif user.admin?
      where(administrating_organisation_id: user.administrating_organisation_id)
    end
  }

end
