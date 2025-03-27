# == Schema Information
#
# Table name: impact_card_data_models
#
#  id           :bigint           not null, primary key
#  color        :string           default("#0d9488"), not null
#  deleted_at   :datetime
#  description  :string
#  metadata     :jsonb
#  name         :string           not null
#  short_name   :string
#  status       :string           default("active"), not null
#  system_model :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  workspace_id :bigint
#
# Indexes
#
#  index_impact_card_data_models_on_name_and_workspace_id  (name,workspace_id) UNIQUE WHERE ((workspace_id IS NOT NULL) AND (deleted_at IS NULL))
#  index_impact_card_data_models_on_workspace_id           (workspace_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_id => workspaces.id)
#
require 'rails_helper'

RSpec.describe ImpactCardModel, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
