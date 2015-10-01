class Initiative < ActiveRecord::Base
  belongs_to :scorecard
  # TODO Add a validation to ensure that organistions belong to same
  # administrating organisation as the initiative. NB this might be an argument
  # for converting the join table into a proper model and adding validations to
  # it
  has_and_belongs_to_many :organisations, join_table: :initiatives_organisations
  has_many :checklist_items

  validates :scorecard, presence: true

  scope :for_user, ->(user) {
    unless user.staff?
      joins(:scorecard).where(
        'scorecards.client_id' => user.client_id
      )
    end
  }

  after_create :create_checklist_items

  private

    def create_checklist_items
      Characteristic.all.each do |characteristic|
        ChecklistItem.create!(
          initiative: self, characteristic: characteristic
        )
      end
    end
end
