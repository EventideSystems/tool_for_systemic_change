
# Backup of original seeds.rb file, with the following changes:
# - Removed Focus Area Groups, Focus Areas and Characteristics related to legacy IP
# - Removed Video Tutorials related to legacy IP
# - Removed any data that might be related to existing users

# NOTE Code used to extract Focus Area Groups, Focus Areas and Characteristics from production, if
# we ever need to re-create the seed data:
#
# focus_area_groups = FocusAreaGroup.all.each_with_object([]) do |fa_group, fa_group_array|
#   fa_group_hash = fa_group.attributes.with_indifferent_access.symbolize_keys.slice(:name, :position)
#   fa_group_hash[:focus_areas] = fa_group.focus_areas.all.each_with_object([]) do |fa, fa_array|
#     fa_hash = fa.attributes.with_indifferent_access.symbolize_keys.slice(:name, :position)
#     fa_hash[:characteristics] = fa.characteristics.all.each_with_object([]) do |c, c_array|
#       c_hash = c.attributes.with_indifferent_access.symbolize_keys.slice(:name, :position)
#       c_array << c_hash
#     end
#     fa_array << fa_hash
#   end
#   fa_group_array << fa_group_hash
# end
#
# pp focus_area_groups


raise 'DO NOT RUN IN PRODUCTION!' if Rails.env.production?
raise 'MISSING SEED_USER_PASSWORD ENV VAR' if ENV['SEED_USER_PASSWORD'].blank?

# Stakeholder Types (template types)
[
  { name: 'Business', color: '#FF6D24' },
  { name: 'Social Enterprise', color: '#F7C80B' },
  { name: 'Education', color: '#FF5353' },
  { name: 'Formal community group', color: '#914bb4' },
  { name: 'Informal community group', color: '#7993F2' },
  { name: 'Individual', color: '#FD9ACA' },
  { name: 'Non-government Organisations', color: '#2E74BA' },
  { name: 'Not for profit', color: '#009BCC' },
  { name: 'Local government', color: '#008C8C' },
  { name: 'State government', color: '#00CCAA' },
  { name: 'Federal government', color: '#1CB85D' },
  { name: 'Indigenous Business', color: '#000000' }
].each do |stakeholder_type_attributes|
  StakeholderType
    .create_with(stakeholder_type_attributes.slice(:color))
    .find_or_create_by!(stakeholder_type_attributes.slice(:name))
end

# Accounts

[
  { name: 'Default account' },
  { name: 'Client account' }
].each do |account_attributes|
  Account.find_or_create_by!(account_attributes)
end

# Users

seed_user_password = ENV['SEED_USER_PASSWORD']

admin_user = User.where(email: 'test-admin@wickedlab.com.au').first_or_initialize
admin_user.name = 'Test Admin'
admin_user.password = admin_user.password_confirmation = seed_user_password
admin_user.system_role = 'admin'
admin_user.save!

staff_user = User.where(email: 'test-staff@wickedlab.com.au').first_or_initialize
staff_user.name = 'Test Staff'
staff_user.password = staff_user.password_confirmation = seed_user_password
staff_user.save!


AccountsUser.find_or_create_by!(
  user: staff_user,
  account: Account.find_by(name: 'Client account'),
  account_role: 'admin'
)

user = User.where(email: 'test-user@wickedlab.com.au').first_or_initialize
user.name = 'Test User'
user.password = user.password_confirmation = seed_user_password
user.save!

AccountsUser.find_or_create_by!(
  user: user,
  account: Account.find_by(name: 'Client account'),
  account_role: 'member'
)


default_account = Account.find_by(name: 'Default account')

[
  'South West Western Australia',
  'South Australia',
  'Fleurieu Peninsula (Patpangga)',
  'Adelaide CBD & Greater Metro Region',
  'Clare Valley (Kyneetcha)'
].each do |community_name|
  Community
    .create_with(name: community_name, account: default_account)
    .find_or_create_by!(name: community_name, account: default_account)
end

[
  'Food Security',
  'Greening',
  'Disaster Resilience',
  'Consumption and Waste'
].each do |wicked_problem_name|
  WickedProblem
    .create_with(name: wicked_problem_name, account: default_account)
    .find_or_create_by!(name: wicked_problem_name, account: default_account)
end

[
  'Climate and environment (private land)',
  'Culture and community (private land)',
  'Funding and investment (private land)',
  'Knowledge and skills (private land)',
  'Knowledge and skills (public land)',
  'Policy and planning (private land)',
  'Private land only',
  'Public land only',
  'Culture and community (public land)',
  'Climate and environment (public land)',
  'Policy and planning (public land)',
  'Culture and community (public land), Private and public land',
  'Policy and planning (public land), Private and public land',
  'Private and public land',
  'Funding and investment (public land)',
  'Funding and investment (public land), Private and public land',
  'Food availability',
  'Food access',
  'Food utilisation',
  'Children and Young People',
  'Small Business',
  'Neighbourhoods and Communities',
  'Strategic and Connected Networks',
  'Diversity and Inclusion',
  'Health and wellbeing',
  'Public Informaton Campaign',
  'Enterprise',
  'Education',
  'Research',
  'Community',
  'CBD',
].each do |subsystem_tag_name|
  SubsystemTag
    .create_with(name: subsystem_tag_name, account: default_account)
    .find_or_create_by!(name: subsystem_tag_name, account: default_account)
end
