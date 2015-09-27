class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :client, class_name: 'Client'

  enum role: [ :user, :admin, :staff ]

  validates :client_id, presence: true,
    unless: Proc.new { |u| u.staff? }

  scope :for_user, ->(user) {
    if user.user?
      where(id: user.id)
    elsif user.admin?
      where(client_id: user.client_id)
    end
  }

  def status
    return 'invitation-pending' unless invitation_token.blank?
    return 'active'
  end

end
