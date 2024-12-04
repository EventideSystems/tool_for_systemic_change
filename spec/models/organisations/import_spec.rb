# frozen_string_literal: true

# == Schema Information
#
# Table name: imports
#
#  id          :integer          not null, primary key
#  import_data :text
#  status      :integer          default("pending")
#  type        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  account_id  :integer
#  user_id     :integer
#
# Indexes
#
#  index_imports_on_account_id  (account_id)
#  index_imports_on_user_id     (user_id)
#
require 'rails_helper'
