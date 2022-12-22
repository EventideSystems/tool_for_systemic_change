
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


# Video Tutorials without linked record
[
  {
    link_url:              "https://vimeo.com/23921011",
    name:                  "And here's a kitten",
    description:           "",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/208056324",
    name:                  "test 2",
    description:           "<p>you'll learn about blah bah</p>",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/208056324",
    name:                  "Test 2",
    description:           "<p><br></p>",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/208056324",
    name:                  "Test video",
    description:           "<p>test</p>",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/209712386/607c549a71",
    name:                  "test",
    description:           "",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/208056324/9becb4959e",
    name:                  "private test",
    description:           "<p>private test</p>",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/209882272",
    name:                  "Communities",
    description:           "<p>Learn how to create, modify and delete Communities</p>",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/209883953",
    name:                  "Organisations",
    description:           "<p>Learn how to create, modify and delete organisations</p>",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/210096801/5d2c24697b",
    name:                  "Scorecard",
    description:           "<p>Learn how to create a scorecard</p>",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/210096882/4963a946f7",
    name:                  "Initiatives",
    description:           "<p>Learn how to create, modify and delete initiatives</p>",
    promote_to_dashboard:  true
  },
  {
    link_url:              "https://vimeo.com/210098676/b40f4fd02c",
    name:                  "Email and print scorecard",
    description:           "<p>Email, print and share your scorecards<br></p>",
    promote_to_dashboard:  "f",
  },
  {
    link_url:              "https://vimeo.com/209712386",
    name:                  "Wicked Problems",
    description:           "<p>Learn how to create, modify and delete wicked problems</p>",
    promote_to_dashboard:  true
  }
].each do |video_tutorial_attributes|
  VideoTutorial
    .create_with(video_tutorial_attributes.slice(:link_url, :description, :promote_to_dashboard))
    .find_or_create_by!(video_tutorial_attributes.slice(:name))
end


# Video Tutorials linked to Characteristics

[
  {
    link_url:             "https://vimeo.com/208056324/9becb4959e",
    name:                 "Test video",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Highlight the need to organise communities differently",
  },
  {
    link_url:             "https://vimeo.com/218604459/c3dad3066e",
    name:                 "Need to organise differently",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Highlight the need to organise communities differently",
  },
  {
    link_url:             "https://vimeo.com/218604444/41c08b5bf2",
    name:                 "Cultivate a passion for action",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Cultivate a passion for action",
  },
  {
    link_url:             "https://vimeo.com/218604455/dc1fca9256",
    name:                 "Manage initial starting conditions",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Manage initial starting conditions",
  },
  {
    link_url:             "https://vimeo.com/218604463/311d1a815e",
    name:                 "Specify goals in advance",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Specify goals in advance",
  },
  {
    link_url:             "https://vimeo.com/218604454/ebaa79518f",
    name:                 "Establish appropriate boundaries",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Establish appropriate boundaries",
  },
  {
    link_url:             "https://vimeo.com/218604450/47c945f893",
    name:                 "Embrace Uncertainty",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Embrace uncertainty",
  },
  {
    link_url:             "https://vimeo.com/218604440/145cf7ffa5",
    name:                 "Create controversy",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Create controversy",
  },
  {
    link_url:             "https://vimeo.com/218603507/c35aefb486",
    name:                 "Enable safe fail experimentation",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Enable safe fail experimentation",
  },
  {
    link_url:             "https://vimeo.com/218603505/eab6b8809c",
    name:                 "Enabling rich interactions in relational spaces",
    description:          "<p><br></p>",
    promote_to_dashboard: false,
    characteristic_name:  "Enable rich interactions in relational spaces",
  },
  {
    link_url:             "https://vimeo.com/218603527/17c694a76e",
    name:                 "Support collective action",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Support collective action",
  },
  {
    link_url:             "https://vimeo.com/218603520/65bfb1932b",
    name:                 "Partition the system",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Partition the system",
  },
  {
    link_url:             "https://vimeo.com/218603511/ff78a84fe3",
    name:                 "Establish network linkages",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Establish network linkages",
  },
  {
    link_url:             "https://vimeo.com/218603514/833160ecee",
    name:                 "Frame issues to match diverse perspectives",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Frame issues to match diverse perspectives",
  },
  {
    link_url:             "https://vimeo.com/218605174/f445690c5e",
    name:                 "Create correlation through language and symbols",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Create correlation through language and symbols",
  },
  {
    link_url:             "https://vimeo.com/218605189/eeaf6a2bd1",
    name:                 "Encourage individuals to accept positions as role models",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Encourage individuals to accept positions as role models for the change effort",
  },
  {
    link_url:             "https://vimeo.com/218605178/a8448ddd52",
    name:                 "Enable information exchanges between subsystems",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Enable periodic information exchanges between partitioned subsystems",
  },
  {
    link_url:             "https://vimeo.com/218605182/542c68e869",
    name:                 "Enable resources and capabilities to recombine",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Enable resources and capabilities to recombine",
  },
  {
    link_url:             "https://vimeo.com/218605331/f41526a5e2",
    name:                 "Integrate local constraints",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Integrate local constraints",
  },
  {
    link_url:             "https://vimeo.com/218605333/b58f147244",
    name:                 "Provide multiple perspective structure",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Provide a multiple perspective context and system structure",
  },
  {
    link_url:             "https://vimeo.com/218605328/8105ddb880",
    name:                 "Enable problem representations to anchor in the community",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Enable problem representations to anchor in the community",
  },
  {
    link_url:             "https://vimeo.com/218605325/82d5f17cdd",
    name:                 "Enable emergent outcomes to be monitored",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Enable emergent outcomes to be monitored",
  },
  {
    link_url:             "https://vimeo.com/218605055/6ce29eca2f",
    name:                 "Assist system members to keep informed & knowledgable of influencing forces",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Assist system members to keep informed and knowledgeable of forces influencing their community system",
  },
  {
    link_url:             "https://vimeo.com/218605053/532f06a801",
    name:                 "Assist in the connection, dissemination and processing of information",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Assist in the connection, dissemination and processing of information",
  },
  {
    link_url:             "https://vimeo.com/218605057/71d3ea1de0",
    name:                 "Enable connectivity between people who have different perspectives",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Enable connectivity between people who have different perspectives on community issues",
  },
  {
    link_url:             "https://vimeo.com/218605062/b6a71edd13",
    name:                 "Retain and reuse knowledge and ideas generated through interactions",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Retain and reuse knowledge and ideas generated through interactions",
  },
  {
    link_url:             "https://vimeo.com/226725201/ea3853592a",
    name:                 "Assist public administrators to frame policies in a manner which enables community adaptation of policies",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Assist public administrators to frame policies in a manner which enables community adaptation of policies",
  },
  {
    link_url:             "https://vimeo.com/226725521/1fd49d5a5e",
    name:                 "Encourage and assist street level workers to take into account the ideas and views of citizens",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Encourage and assist street level workers to take into account the ideas and views of citizens",
  },
  {
    link_url:             "https://vimeo.com/218604466/8d7da41a65",
    name:                 "Surface conflict",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Surface conflict",
  },
  {
    link_url:             "https://vimeo.com/226725401/cd1cce91a2",
    name:                 "Remove information differences to enable the ideas and views of citizens to align to the challenges being addressed by governments",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Remove information differences to enable the ideas and views of citizens to align to the challenges being addressed by governments",
  },
  {
    link_url:             "https://vimeo.com/226725751/033a126756",
    name:                 "Assist elected members to frame policies in a manner which enables community adaptation of policies",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Assist elected members to frame policies in a manner which enables community adaptation of policies",
  },
  {
    link_url:             "https://vimeo.com/226726113/4caa02ef3c",
    name:                 "Assist elected members to take into account the ideas and views of citizens",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Assist elected members to take into account the ideas and views of citizens",
  },
  {
    link_url:             "https://vimeo.com/226726605/449d14ed48",
    name:                 "Encourage and assist street level workers to exploit the knowledge, ideas and innovations of citizens",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Encourage and assist street level workers to exploit the knowledge, ideas and innovations of citizens",
  },
  {
    link_url:             "https://vimeo.com/226726836/bdd24c8b7d",
    name:                 "Bridge community-led activities and projects to the strategic plans of governments",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Bridge community-led activities and projects to the strategic plans of governments",
  },
  {
    link_url:             "https://vimeo.com/226727094/24c3985bdd",
    name:                 "Gather, retain and reuse community knowledge and ideas in other contexts ",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Gather, retain and reuse community knowledge and ideas in other contexts",
  },
  {
    link_url:             "https://vimeo.com/226727355/2016c8e78a",
    name:                 "Encourage and assist elected members to exploit the knowledge, ideas and innovations of citizens",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Encourage and assist elected members to exploit the knowledge, ideas and innovations of citizens",
  },
  {
    link_url:             "https://vimeo.com/226727498/8037b2d5c9",
    name:                 "Collect, analyse, synthesise, reconfigure, manage and represent community information that is relevant to the electorate or area of portfolio responsibility of elected members",
    description:          "",
    promote_to_dashboard: false,
    characteristic_name:  "Collect, analyse, synthesise, reconfigure, manage and represent community information that is relevant to the electorate or area of portfolio responsibility of elected members"
  }
].each do |video_tutorial_attributes|
  characteristic = Characteristic.find_by(name: video_tutorial_attributes[:characteristic_name])

  attributes = video_tutorial_attributes
    .slice(:link_url, :description, :promote_to_dashboard)
    .merge({linked_type: 'Characteristic', linked_id: characteristic.id})

  VideoTutorial
    .create_with(attributes)
    .find_or_create_by!(video_tutorial_attributes.slice(:name))
end

# Video Tutorials linked to FocusAreaGroups

[
  {
    link_url:              "https://vimeo.com/218602461/acaa0a10ee",
    name:                  "Adaptive Capacity",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_group_name: "Building Adaptive Capacity of Communities"
  },
  {
    link_url:              "https://vimeo.com/226724988/1a3e8e1e6a",
    name:                  "Unplanned Exploration of Solutions with Communities",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_group_name: "Unplanned Exploration of Solutions with Communities"
  },
  {
    link_url:              "https://vimeo.com/226727577/faebd8f3aa",
    name:                  "Planned Exploitation of Community Knowledge, Ideas and Innovations",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_group_name: "Planned Exploitation of Community Knowledge, Ideas and Innovations"
  }
].each do |video_tutorial_attributes|
  focus_area_group = FocusAreaGroup.find_by(name: video_tutorial_attributes[:focus_area_group_name])

  attributes = video_tutorial_attributes
    .slice(:link_url, :description, :promote_to_dashboard)
    .merge({linked_type: 'FocusAreaGroup', linked_id: focus_area_group.id})

  VideoTutorial
    .create_with(attributes)
    .find_or_create_by!(video_tutorial_attributes.slice(:name))
end


# Video Tutorials linked to FocusAreas

[
  {
    link_url:              "https://vimeo.com/218602793/72e33c1957",
    name:                  "Amplify Action",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_name:       "Amplify action",
  },
  {
    link_url:              "https://vimeo.com/218604390/19fedf6458",
    name:                  "Create a Disequilibrium State",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_name:       "Create a disequilibrium state",
  },
  {
    link_url:              "https://vimeo.com/218605112/630f48676d",
    name:                  "Encourage self-organisation",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_name:       "Encourage self-organisation",
  },
  {
    link_url:              "https://vimeo.com/218605240/1b277657f9",
    name:                  "Stabilize feedback",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_name:       "Stabilise feedback",
  },
  {
    link_url:              "https://vimeo.com/218604996/98f3c9a2d9",
    name:                  "Enable information flows",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_name:       "Enable information flows",
  },
  {
    link_url:              "https://vimeo.com/226725108/6585689d7d",
    name:                  "Focus Area 6:  Government bureaucracy - community interface",
    description:           "<p><br></p>",
    promote_to_dashboard:  false,
    focus_area_name:       "Public administration – adaptive community interface",
  },
  {
    link_url:              "https://vimeo.com/226725694/562efc53a1",
    name:                  " Focus Area 7: Government elected members - community interface",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_name:       "Elected government – adaptive community interface",
  },
  {
    link_url:              "https://vimeo.com/226726453/0aa054d147",
    name:                  "Focus Area 8: Community - government bureaucracy interface",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_name:       "Community innovation – public administration interface",
  },
  {
    link_url:              "https://vimeo.com/226727275/8820f843a5",
    name:                  "Focus Area 9: Community - government elected members interface",
    description:           "",
    promote_to_dashboard:  false,
    focus_area_name:       "Community innovation – elected government interface",
  }
].each do |video_tutorial_attributes|
  focus_area = FocusArea.find_by(name: video_tutorial_attributes[:focus_area_name])

  attributes = video_tutorial_attributes
    .slice(:link_url, :description, :promote_to_dashboard)
    .merge({linked_type: 'FocusArea', linked_id: focus_area.id})

  VideoTutorial
    .create_with(attributes)
    .find_or_create_by!(video_tutorial_attributes.slice(:name))
end

default_account = Account.find_by(name: 'Default account')

[
  'South West Western Australia',
  'Urban greening',
  'Suburbs of Marion, Park Holme and Oaklands Park',
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
  'test',
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
  'Subsystem Test',
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
