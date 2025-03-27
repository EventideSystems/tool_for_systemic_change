# frozen_string_literal: true

# == Schema Information
#
# Table name: communities
#
#  id           :integer          not null, primary key
#  color        :string           default("#15d154"), not null
#  deleted_at   :datetime
#  description  :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :integer
#
# Indexes
#
#  index_communities_on_deleted_at    (deleted_at)
#  index_communities_on_workspace_id  (workspace_id)
#
class Community < ApplicationRecord
  include Searchable
  include RandomColorAttribute
  include ExportToCsv

  has_paper_trail
  acts_as_paranoid

  belongs_to :workspace
  has_many :scorecards, dependent: :nullify

  validates :workspace, presence: true
  # TODO: Add validation to database, or remove this model completely
  validates :name, presence: true, uniqueness: { scope: :workspace_id } # rubocop:disable Rails/UniqueValidationWithoutIndex

  csv_attributes :name, :description, :color
end
