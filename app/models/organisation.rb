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
#  account_id          :integer
#  stakeholder_type_id :integer
#
# Indexes
#
#  index_organisations_on_account_id  (account_id)
#  index_organisations_on_deleted_at  (deleted_at)
#
class Organisation < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :account
  belongs_to :stakeholder_type
  has_many :initiatives_organisations, dependent: :delete_all
  has_many :initiatives, through: :initiatives_organisations

  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }
  validates :stakeholder_type_id, presence: true
  validate :stakeholder_type_is_in_same_account

  delegate :name, to: :stakeholder_type, prefix: true, allow_nil: true

  accepts_nested_attributes_for :initiatives_organisations, reject_if: :all_blank, allow_destroy: true

  private

  def stakeholder_type_is_in_same_account
    errors.add(:stakeholder_type_id, "must be in the same account") if stakeholder_type && stakeholder_type.account != account
  end
end
