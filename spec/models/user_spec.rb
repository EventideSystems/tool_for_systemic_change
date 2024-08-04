# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  deleted_at             :datetime
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  invitation_accepted_at :datetime
#  invitation_created_at  :datetime
#  invitation_limit       :integer
#  invitation_sent_at     :datetime
#  invitation_token       :string
#  invitations_count      :integer          default(0)
#  invited_by_type        :string
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  name                   :string
#  profile_picture        :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  system_role            :integer          default("member")
#  time_zone              :string           default("Adelaide")
#  created_at             :datetime
#  updated_at             :datetime
#  invited_by_id          :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE WHERE (deleted_at IS NULL)
#  index_users_on_invitation_token      (invitation_token) UNIQUE
#  index_users_on_invitations_count     (invitations_count)
#  index_users_on_invited_by_id         (invited_by_id)
#  index_users_on_name                  (name)
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_system_role           (system_role)
#
require 'rails_helper'

RSpec.describe VideoTutorial, type: :model do
  
  it 'allows a user to be recreated after a delete' do
    user = User.create!(email: 'foo@bar.com', password: 'q2341234213', password_confirmation: 'q2341234213')
    user.delete
    
    expect{ User.create!(email: 'foo@bar.com', password: 'q2341234213', password_confirmation: 'q2341234213') }
      .to_not raise_exception
  end
end  
