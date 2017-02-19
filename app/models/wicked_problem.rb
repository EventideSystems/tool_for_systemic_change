class WickedProblem < ApplicationRecord
  acts_as_paranoid

  include Trackable

  belongs_to :account
  has_many :scorecards, dependent: :restrict_with_error

  validates :account, presence: true
  validates :name, presence: true, :uniqueness => { :scope => :account_id }

  def description_summary
    Nokogiri::HTML(description).text
  end
end