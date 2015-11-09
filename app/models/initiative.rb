class Initiative < ActiveRecord::Base
  include Trackable

  belongs_to :scorecard
  # TODO: Add a validation to ensure that organistions belong to same
  # administrating organisation as the initiative. NB this might be an argument
  # for converting the join table into a proper model and adding validations to
  # it
  has_and_belongs_to_many :organisations, join_table: :initiatives_organisations
  has_many :checklist_items
  has_many :characteristics, through: :checklist_items

  validates :scorecard, presence: true
  validate :finished_at_later_than_started_at

  scope :for_user, lambda { |user|
    unless user.staff?
      joins(:scorecard).where(
        "scorecards.client_id" => user.client_id
      )
    end
  }

  after_create :create_checklist_items

  private

  def create_checklist_items
    Characteristic.all.find_each do |characteristic|
      ChecklistItem.create!(
        initiative: self, characteristic: characteristic
      )
    end
  end

  def finished_at_later_than_started_at
    if started_at.present? && finished_at.present? && finished_at < started_at
      errors.add(:finished_at, "can't be earlier than started at date")
    end
  end
end
