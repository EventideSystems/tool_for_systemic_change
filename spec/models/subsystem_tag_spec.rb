# frozen_string_literal: true

# == Schema Information
#
# Table name: subsystem_tags
#
#  id           :integer          not null, primary key
#  color        :string           default("#824b54"), not null
#  deleted_at   :datetime
#  description  :string
#  name         :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :integer
#
# Indexes
#
#  index_subsystem_tags_on_deleted_at    (deleted_at)
#  index_subsystem_tags_on_workspace_id  (workspace_id)
#
require 'rails_helper'

RSpec.describe SubsystemTag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
