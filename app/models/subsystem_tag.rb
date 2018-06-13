class SubsystemTag < ApplicationRecord
  has_paper_trail
  acts_as_paranoid

  belongs_to :account
  has_many :initiatives_subsystem_tags, dependent: :delete_all
  has_many :initiatives, through: :initiatives_subsystem_tags

  validates :account, presence: true
  validates :name, presence: true, uniqueness: { scope: :account_id }  
end
