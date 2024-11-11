# frozen_string_literal: true

# == Schema Information
#
# Table name: scorecards
#
#  id                         :integer          not null, primary key
#  deleted_at                 :datetime
#  description                :string
#  name                       :string
#  share_ecosystem_map        :boolean          default(TRUE)
#  share_thematic_network_map :boolean          default(TRUE)
#  type                       :string           default("TransitionCard")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  account_id                 :integer
#  community_id               :integer
#  linked_scorecard_id        :integer
#  shared_link_id             :string
#  wicked_problem_id          :integer
#
# Indexes
#
#  index_scorecards_on_account_id  (account_id)
#  index_scorecards_on_deleted_at  (deleted_at)
#  index_scorecards_on_type        (type)
#
class Scorecard < ApplicationRecord
  include Searchable

  has_paper_trail
  acts_as_paranoid

  after_initialize :ensure_shared_link_id, if: :new_record?

  belongs_to :community, optional: true
  belongs_to :account
  belongs_to :wicked_problem, optional: true
  belongs_to :linked_scorecard, class_name: 'Scorecard', optional: true

  has_many :initiatives, -> { order('lower(initiatives.name)') }, dependent: :destroy
  has_many :checklist_items, through: :initiatives
  has_many :initiatives_organisations, through: :initiatives
  has_many :subsystem_tags, through: :initiatives

  has_many :organisations, through: :initiatives_organisations
  has_many :scorecard_changes

  has_rich_text :notes

  delegate :name, :description, to: :wicked_problem, prefix: true, allow_nil: true
  delegate :name, :description, to: :community, prefix: true, allow_nil: true

  delegate :stakeholder_types, to: :account

  accepts_nested_attributes_for :initiatives,
                                allow_destroy: true,
                                reject_if: proc { |attributes| attributes['name'].blank? }

  validates :account, presence: true
  validates :name, presence: true
  validates :shared_link_id, uniqueness: true
  validate :linked_scorecard_must_be_in_same_account

  before_save :set_inverse_linked_scorecard, if: :linked_scorecard_id_changed?

  def set_inverse_linked_scorecard
    Scorecard.find(linked_scorecard_id_was).update_column(:linked_scorecard_id, nil) if linked_scorecard_id_was.present?

    Scorecard.find(linked_scorecard_id).update_column(:linked_scorecard_id, id) if linked_scorecard_id.present?

    true
  end

  def description_summary
    Nokogiri::HTML(description).text
  end

  def linked?
    linked_scorecard_id.present?
  end

  def merge(other_scorecard)
    existing_initiative_names = initiatives.pluck(:name)

    other_scorecard.initiatives.each do |initiative|
      name = non_clashing_initiative_name(initiative.name, existing_initiative_names)
      existing_initiative_names << name unless existing_initiative_names.include?(name)

      initiative.update(scorecard_id: id, name: name)
    end

    other_scorecard.delete

    reload
  end

  def new_shared_link_id
    SecureRandom.uuid
  end

  def unique_organisations
    organisations.uniq
  end

  private

  def linked_scorecard_must_be_in_same_account
    return unless linked_scorecard.present? && linked_scorecard.account != account

    errors.add(:linked_scorecard_id, 'must be in the same account')
  end

  def non_clashing_initiative_name(name, existing_names)
    return name unless existing_names.include?(name)

    name_match = /(.*)(\s\(\d+\))$/.match(name)
    basename = name_match ? name_match[1] : name

    count = 1
    loop do
      new_name = "#{basename} (#{count})"
      return new_name unless existing_names.include?(new_name)

      count += 1
    end
  end

  def ensure_shared_link_id
    self.shared_link_id ||= new_shared_link_id
  end
end
