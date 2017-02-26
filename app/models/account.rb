# frozen_string_literal: true
class Account < ApplicationRecord
  acts_as_paranoid

  include Trackable

  belongs_to :sector
  has_many :accounts_users
  has_many :users, through: :accounts_users
  has_many :organisations
  has_many :communities
  has_many :scorecards
  has_many :initiatives, through: :scorecards
  has_many :wicked_problems
end

