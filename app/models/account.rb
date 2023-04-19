# frozen_string_literal: true

class Account < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  EXPIRY_WARNING_PERIOD = 30.days

  enum subcription_type: { standard: 0, twelve_month_single_scorecard: 1 }

  belongs_to :stakeholder_type, optional: true
  has_many :accounts_users
  has_many :users, through: :accounts_users
  has_many :organisations
  has_many :communities
  has_many :scorecards
  has_many :initiatives, through: :scorecards
  has_many :wicked_problems
  has_many :organisations_imports, class_name: 'Organisations::Import'
  has_many :initiatives_imports, class_name: 'Initiatives::Import'
  has_many :scorecard_comments_imports, class_name: 'ScorecardComments::Import'
  has_many :subsystem_tags
  has_many :stakeholder_types, dependent: :destroy

  validates :name, presence: true

  after_create :create_stakeholder_types

  scope :active,
        lambda {
          where(expires_on: nil).or(::Account.where(expires_on: Date.today..)).order(created_at: :asc)
        }

  scope :expiring_soon,
        lambda {
          where(expires_on: Date.today..(Date.today + EXPIRY_WARNING_PERIOD)).order(created_at: :asc)
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

  def create_stakeholder_types
    StakeholderType.system_stakeholder_types.each do |template|
      template
        .dup
        .tap { |s| s.account = self }
        .save!
    end
  end
end
