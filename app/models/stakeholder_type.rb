# frozen_string_literal: true

# == Schema Information
#
# Table name: stakeholder_types
#
#  id          :integer          not null, primary key
#  color       :string
#  deleted_at  :datetime
#  description :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#
# Indexes
#
#  index_stakeholder_types_on_account_id  (account_id)
#
class StakeholderType < ApplicationRecord
  include Searchable
  include RandomColorAttribute
  include ExportToCsv

  acts_as_paranoid

  validates :name, presence: true

  belongs_to :account, optional: true
  has_many :organisations, dependent: :nullify

  before_destroy :check_no_longer_used!, prepend: true

  scope :system_stakeholder_types, -> { where(account_id: nil) }

  validates :name, presence: true, uniqueness: { scope: :account_id } # rubocop:disable Rails/UniqueValidationWithoutIndex

  alias stakeholders organisations

  csv_attributes :name, :description, :color, :stakeholders_count

  # def self.to_csv
  #   attributes = %w[name color description stakeholders_count]

  #   CSV.generate(headers: true) do |csv|
  #     csv << attributes

  #     all.find_each do |user|
  #       csv << attributes.map { |attr| user.send(attr) }
  #     end
  #   end
  # end

  def in_use? = organisations.any?
  def system_stakeholder_type? = account_id.nil?

  delegate :count, to: :stakeholders, prefix: true, allow_nil: true

  private

  def check_no_longer_used!
    return true if organisations.empty?

    errors.add(:base, 'This stakeholder type is still in use')
    throw(:abort)
  end
end
