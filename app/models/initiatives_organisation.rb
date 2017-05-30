# frozen_string_literal: true
class InitiativesOrganisation < ApplicationRecord
  has_paper_trail
  #validates :initiative, :organisation, presence: true

  belongs_to :initiative
  belongs_to :organisation
end
