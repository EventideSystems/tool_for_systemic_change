# frozen_string_literal: true
class InitiativesSubsystemTag < ApplicationRecord
  has_paper_trail

  belongs_to :initiative
  belongs_to :subsystem_tag
end