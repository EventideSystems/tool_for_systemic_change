class Initiative < ActiveRecord::Base
  belongs_to :wicked_problem
  has_and_belongs_to_many :organisations, join_table: :initiatives_organisations

  # TODO Add a validation to ensure that organistions belong to same
  # administrating organisation as the initiative. NB this might be an argument
  # for converting the join table into a proper model and adding validations to
  # it

  scope :for_user, ->(user) {
    unless user.staff?
      joins(:wicked_problem).where(
        'wicked_problems.administrating_organisation_id' => user.administrating_organisation_id
      )
    end
  }
end
