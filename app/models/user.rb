class User < ActiveRecord::Base
  acts_as_paranoid

  include Trackable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable

  handle_asynchronously :send_devise_notification, :queue => 'devise'

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
    return 'deleted' unless deleted_at.blank?
    return 'invitation-pending' unless invitation_token.blank?
    return 'active'
  end

  def displayed_name
    name.present? ? name : email
  end

end
