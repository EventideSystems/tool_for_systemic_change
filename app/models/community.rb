# frozen_string_literal: true

# == Schema Information
#
# Table name: communities
#
#  id          :integer          not null, primary key
#  color       :string           default("#14b8a6"), not null
#  deleted_at  :datetime
#  description :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#
# Indexes
#
#  index_communities_on_account_id  (account_id)
#  index_communities_on_deleted_at  (deleted_at)
#
class Community < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :account
  has_many :scorecards

  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name description] + _ransackers.keys
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
