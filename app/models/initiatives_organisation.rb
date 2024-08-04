# frozen_string_literal: true

# == Schema Information
#
# Table name: initiatives_organisations
#
#  id              :integer          not null, primary key
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  initiative_id   :integer          not null
#  organisation_id :integer          not null
#
# Indexes
#
#  index_initiatives_organisations_on_deleted_at                  (deleted_at)
#  index_initiatives_organisations_on_initiative_id               (initiative_id)
#  index_initiatives_organisations_on_initiative_organisation_id  (initiative_id,organisation_id) UNIQUE
#
class InitiativesOrganisation < ApplicationRecord
  has_paper_trail
  #validates :initiative, :organisation, presence: true

  belongs_to :initiative
  belongs_to :organisation
end
