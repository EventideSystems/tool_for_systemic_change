# frozen_string_literal: true
class Sector < ApplicationRecord
  acts_as_paranoid

  has_many :accounts
end
