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
require 'rails_helper'

RSpec.describe SubsystemTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
