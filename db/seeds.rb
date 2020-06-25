
raise 'DO NOT RUN IN PRODUCTION!' if Rails.env.production?
raise 'MISSING SEED_USER_PASSWORD ENV VAR' if ENV['SEED_USER_PASSWORD'].blank?

# Sectors
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
].each do |sector_attributes|
  Sector
    .create_with(sector_attributes.slice(:color))
    .find_or_create_by!(sector_attributes.slice(:name))
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

# Focus Area Groups, Focus Areas and Characteristics

# NOTE Code used to extract data from production
#
# focus_area_groups = FocusAreaGroup.all.each_with_object([]) do |fag, fag_array|
#   fag_hash = fag.attributes.with_indifferent_access.symbolize_keys.slice(:name, :position)
#   fag_hash[:focus_areas] = fag.focus_areas.all.each_with_object([]) do |fa, fa_array|
#     fa_hash = fa.attributes.with_indifferent_access.symbolize_keys.slice(:name, :position)   
#     fa_hash[:characteristics] = fa.characteristics.all.each_with_object([]) do |c, c_array|
#       c_hash = c.attributes.with_indifferent_access.symbolize_keys.slice(:name, :position)
#       c_array << c_hash
#     end
#     fa_array << fa_hash
#   end
#   fag_array << fag_hash
# end
#
# pp focus_area_groups

[
  { 
    name: "Building Adaptive Capacity of Communities",
    position: 1,
    focus_areas: [
      { 
        name: "Create a disequilibrium state", 
        position: 1,
        characteristics: [
          { name: "Highlight the need to organise communities differently", position: 1 },
          { name: "Cultivate a passion for action", position: 2 },
          { name: "Manage initial starting conditions", position: 3 },
          { name: "Specify goals in advance", position: 4 },
          { name: "Establish appropriate boundaries", position: 5 },
          { name: "Embrace uncertainty", position: 6 },
          { name: "Surface conflict", position: 7 },
          { name: "Create controversy", position: 8 }
        ] 
      },
      { 
        name: "Amplify action", 
        position: 2,
        characteristics: [
          { name: "Enable safe fail experimentation", position: 1 },
          { name: "Enable rich interactions in relational spaces", position: 2 },
          { name: "Support collective action", position: 3 },
          { name: "Partition the system", position: 4 },
          { name: "Establish network linkages", position: 5 },
          { name: "Frame issues to match diverse perspectives", position: 6 }
        ] 
      },
      { 
        name: "Encourage self-organisation",
        position: 3,
        characteristics: [
          { name: "Create correlation through language and symbols", position: 1 },
          { name: "Encourage individuals to accept positions as role models for the change effort", position: 2 },
          { name: "Enable periodic information exchanges between partitioned subsystems", position: 3 },
          { name: "Enable resources and capabilities to recombine", position: 4 }
        ] 
      },
      { 
        name: "Stabilise feedback",
        position: 4,
        characteristics: [
          { name: "Integrate local constraints", position: 1 },
          { name: "Provide a multiple perspective context and system structure", position: 2 },
          { name: "Enable problem representations to anchor in the community", position: 3 },
          { name: "Enable emergent outcomes to be monitored", position: 4 }
        ] 
      },
      { 
        name: "Enable information flows",
        position: 5,
        characteristics: [
          { name: "Assist system members to keep informed and knowledgeable of forces influencing their community system", position: 1 },
          { name: "Assist in the connection, dissemination and processing of information", position: 2 },
          { name: "Enable connectivity between people who have different perspectives on community issues", position: 3 },
          { name: "Retain and reuse knowledge and ideas generated through interactions", position: 4 }
        ] 
      }
    ] 
  },
  { 
    name: "Unplanned Exploration of Solutions with Communities",
    position: 2,
    focus_areas: [
      { 
        name: "Public administration – adaptive community interface",
        position: 6,
        characteristics: [
          { name: "Assist public administrators to frame policies in a manner which enables community adaptation of policies", position: 1 },
          { name: "Remove information differences to enable the ideas and views of citizens to align to the challenges being addressed by governments", position: 2 },
          { name: "Encourage and assist street level workers to take into account the ideas and views of citizens", position: 3 }
        ] 
      },
      { 
        name: "Elected government – adaptive community interface",
        position: 7,
        characteristics: [
          { name: "Assist elected members to frame policies in a manner which enables community adaptation of policies", position: 1 },
          { name: "Assist elected members to take into account the ideas and views of citizens", position: 2 }
        ] 
      }
    ] 
  },
  { 
    name: "Planned Exploitation of Community Knowledge, Ideas and Innovations",
    position: 3,
    focus_areas: [
      { 
        name: "Community innovation – public administration interface",
        position: 8,
        characteristics: [
          { name: "Encourage and assist street level workers to exploit the knowledge, ideas and innovations of citizens", position: 1 },
          { name: "Bridge community-led activities and projects to the strategic plans of governments", position: 2 },
          { name: "Gather, retain and reuse community knowledge and ideas in other contexts", position: 3 }
        ] 
      },
      { 
        name: "Community innovation – elected government interface",
        position: 9,
        characteristics: [
          { name: "Encourage and assist elected members to exploit the knowledge, ideas and innovations of citizens", position: 1 },
          { name: "Collect, analyse, synthesise, reconfigure, manage and represent community information that is relevant to the electorate or area of portfolio responsibility of elected members", position: 2 }
        ] 
      }
    ] 
  }
].each do |focus_area_group_attributes|
  focus_area_group = FocusAreaGroup
    .create_with(focus_area_group_attributes.slice(:position))
    .find_or_create_by!(focus_area_group_attributes.slice(:name))

  focus_area_group_attributes[:focus_areas].each do |focus_area_attributes| 

    focus_area = focus_area_group
      .focus_areas
      .create_with(focus_area_attributes.slice(:position))
      .find_or_create_by!(focus_area_attributes.slice(:name))

    focus_area_attributes[:characteristics].each do |characteristic_attributes|

      position_param = characteristic_attributes.slice(:position)

      existing_characteristic = focus_area.characteristics.find_by(position_param)

      if existing_characteristic
        if existing_characteristic.name.casecmp(characteristic_attributes[:name]).zero?
          existing_characteristic.update(characteristic_attributes.slice(:name))
          next
        else
          existing_characteristic.delete  
        end
      end

      focus_area
        .characteristics
        .create_with(characteristic_attributes.slice(:position))
        .find_or_create_by!(characteristic_attributes.slice(:name))
    end
  end
end
