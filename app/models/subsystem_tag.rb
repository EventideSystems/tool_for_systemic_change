# == Schema Information
#
# Table name: subsystem_tags
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
#  index_subsystem_tags_on_account_id  (account_id)
#  index_subsystem_tags_on_deleted_at  (deleted_at)
#
class SubsystemTag < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :account
  has_many :initiatives_subsystem_tags, dependent: :delete_all
  has_many :initiatives, through: :initiatives_subsystem_tags

  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }

  alias_attribute :text, :name

  def self.ransackable_attributes(_auth_object = nil)
    %w[name description] + _ransackers.keys
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

end
