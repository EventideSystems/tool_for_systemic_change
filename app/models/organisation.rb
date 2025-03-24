# frozen_string_literal: true

# == Schema Information
#
# Table name: organisations
#
#  id                  :integer          not null, primary key
#  deleted_at          :datetime
#  description         :string
#  name                :string
#  weblink             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  stakeholder_type_id :integer
#  workspace_id        :integer
#
# Indexes
#
#  index_organisations_on_deleted_at    (deleted_at)
#  index_organisations_on_workspace_id  (workspace_id)
#
class Organisation < ApplicationRecord
  include Searchable

  has_paper_trail
  acts_as_paranoid

  belongs_to :workspace
  belongs_to :stakeholder_type
  has_many :initiatives_organisations, dependent: :delete_all
  has_many :initiatives, through: :initiatives_organisations

  validates :workspace, presence: true
  # TODO: Add validation in the database schema
  validates :name, presence: true, uniqueness: { scope: :workspace_id } # rubocop:disable Rails/UniqueValidationWithoutIndex
  validates :stakeholder_type_id, presence: true
  validate :stakeholder_type_is_in_same_workspace

  delegate :name, to: :stakeholder_type, prefix: true, allow_nil: true

  accepts_nested_attributes_for :initiatives_organisations, reject_if: :all_blank, allow_destroy: true

  private

  def stakeholder_type_is_in_same_workspace
    return unless stakeholder_type && stakeholder_type.workspace != workspace

    errors.add(:stakeholder_type_id,
               'must be in the same workspace')
  end
end
