# frozen_string_literal: true

# == Schema Information
#
# Table name: initiatives_subsystem_tags
#
#  id               :integer          not null, primary key
#  deleted_at       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  initiative_id    :integer          not null
#  subsystem_tag_id :integer          not null
#
# Indexes
#
#  idx_initiatives_subsystem_tags_initiative_and_subsystem_tag_id  (initiative_id,subsystem_tag_id) UNIQUE
#  index_initiatives_subsystem_tags_on_deleted_at                  (deleted_at)
#
class InitiativesSubsystemTag < ApplicationRecord
  has_paper_trail

  belongs_to :initiative
  belongs_to :subsystem_tag
end
