class Account < ApplicationRecord
  acts_as_paranoid
    
  belongs_to :sector
end
