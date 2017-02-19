# frozen_string_literal: true
class InitiativesOrganisation < ApplicationRecord
  validates :initiative, :organisation, presence: true

  belongs_to :initiative
  belongs_to :organisation
end
