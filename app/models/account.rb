# frozen_string_literal: true

# == Schema Information
#
# Table name: accounts
#
#  id                                                 :integer          not null, primary key
#  allow_sustainable_development_goal_alignment_cards :boolean          default(FALSE)
#  allow_transition_cards                             :boolean          default(TRUE)
#  deactivated                                        :boolean
#  deleted_at                                         :datetime
#  description                                        :string
#  expires_on                                         :date
#  expiry_warning_sent_on                             :date
#  max_scorecards                                     :integer          default(1)
#  max_users                                          :integer          default(1)
#  name                                               :string
#  sdgs_alignment_card_characteristic_model_name      :string           default("Targets")
#  sdgs_alignment_card_focus_area_group_model_name    :string           default("Focus Area Group")
#  sdgs_alignment_card_focus_area_model_name          :string           default("Focus Area")
#  sdgs_alignment_card_model_name                     :string           default("SDGs Alignment Card")
#  solution_ecosystem_maps                            :boolean
#  transition_card_characteristic_model_name          :string           default("Characteristic")
#  transition_card_focus_area_group_model_name        :string           default("Focus Area Group")
#  transition_card_focus_area_model_name              :string           default("Focus Area")
#  transition_card_model_name                         :string           default("Transition Card")
#  weblink                                            :string
#  welcome_message                                    :text
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#  stakeholder_type_id                                :integer
#
class Account < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  EXPIRY_WARNING_PERIOD = 30.days

  # enum subcription_type: { standard: 0, twelve_month_single_scorecard: 1 }

  belongs_to :stakeholder_type, optional: true

  # Direct associations
  has_many :accounts_users, dependent: :destroy
  has_many :communities, dependent: :destroy
  has_many :focus_area_groups, dependent: :destroy
  has_many :initiatives_imports, class_name: 'Initiatives::Import', dependent: :destroy
  has_many :organisations, dependent: :destroy
  has_many :organisations_imports, class_name: 'Organisations::Import', dependent: :destroy
  has_many :scorecard_comments_imports, class_name: 'ScorecardComments::Import', dependent: :destroy
  has_many :scorecards, dependent: :destroy
  has_many :stakeholder_types, dependent: :destroy
  has_many :subsystem_tags, dependent: :destroy
  has_many :users, through: :accounts_users
  has_many :wicked_problems, dependent: :destroy

  # Through associations
  has_many :initiatives, through: :scorecards

  validates :name, presence: true

  after_create :setup_account

  scope :active,
        lambda {
          where(expires_on: nil).or(::Account.where(expires_on: Time.zone.today..)).order(created_at: :asc)
        }

  scope :expiring_soon,
        lambda {
          where(expires_on: Time.zone.today..(Time.zone.today + EXPIRY_WARNING_PERIOD)).order(created_at: :asc)
        }

  def accounts_users_remaining
    return :unlimited if max_users.zero?

    max_users - accounts_users.count
  end

  def scorecard_types
    @scorecard_types ||=
      [].tap do |types|
        types << TransitionCard if allow_transition_cards?
        types << SustainableDevelopmentGoalAlignmentCard if allow_sustainable_development_goal_alignment_cards?
      end
  end

  def default_scorecard_type
    return scorecard_types.first if scorecard_types.size == 1

    TransitionCard
  end

  def custom_stakeholder_types_in_use?
    StakeholderType.system_stakeholder_types.order(:name).pluck(:name) != stakeholder_types.order(:name).pluck(:name)
  end

  private

  def setup_account = SetupAccount.call(account: self)
end
