# TODO Prevent this from deleting production data. Ideally should be idempotent

FocusAreaGroup.delete_all
FocusArea.delete_all
Characteristic.delete_all

def create_focus_area_group(name)
  group = FocusAreaGroup.find_or_create!(name: name)

  yield group

end

FocusAreaGroup.create!(name: "Unlock Complex Adaptive System Dynamics") do |group|
  group.save!
  group.focus_areas.create!(name: "create! a disequilibrium state") do |area|
    area.save!
    area.characteristics.create!(name: "highlight the need to organise communities differently")
    area.characteristics.create!(name: "cultivate a passion for action")
    area.characteristics.create!(name: "manage initial starting conditions")
    area.characteristics.create!(name: "specify goals in advance")
    area.characteristics.create!(name: "establish appropriate boundaries")
    area.characteristics.create!(name: "embrace uncertainty")
    area.characteristics.create!(name: "surface conflict")
    area.characteristics.create!(name: "create! controversy")
  end

  group.focus_areas.create!(name: "Amplify action") do |area|
    area.save!
    area.characteristics.create!(name: "enable safe fail experimentation")
    area.characteristics.create!(name: "enable rich interactions in relational spaces")
    area.characteristics.create!(name: "support collective action")
    area.characteristics.create!(name: "partition the system")
    area.characteristics.create!(name: "establish network linkages")
    area.characteristics.create!(name: "frame issues to match diverse perspectives")
  end

  group.focus_areas.create!(name: "Encourage self-organisation") do |area|
    area.save!
    area.characteristics.create!(name: "create! correlation through language and symbols")
    area.characteristics.create!(name: "encourage individuals to accept positions as role models for the change effort")
    area.characteristics.create!(name: "enable periodic information exchanges between partitioned subsystems")
    area.characteristics.create!(name: "enable resources and capabilities to recombine")
  end

  group.focus_areas.create!(name: "Stabilise feedback") do |area|
    area.save!
    area.characteristics.create!(name: "integrate local constraints")
    area.characteristics.create!(name: "provide a multiple perspective context and system structure")
    area.characteristics.create!(name: "enable problem representations to anchor in the community")
    area.characteristics.create!(name: "enable emergent outcomes to be monitored")
  end

  group.focus_areas.create!(name: "Enable information flows") do |area|
    area.save!
    area.characteristics.create!(name: "assist system members to keep informed and knowledgeable of forces influencing their community system")
    area.characteristics.create!(name: "assist in the connection, dissemination and processing of information")
    area.characteristics.create!(name: "enable connectivity between people who have different perspectives on community issues")
    area.characteristics.create!(name: "retain and reuse knowledge and ideas generated through interactions")
  end
end

FocusAreaGroup.create!(name: "Unplanned Exploration of Solutions with Communities") do |group|
  group.save!
  group.focus_areas.create!(name: "Public administration – adaptive community interface") do |area|
    area.save!
    area.characteristics.create!(name: "assist public administrators to frame policies in a manner which enables community adaptation of policies")
    area.characteristics.create!(name: "remove information differences to enable the ideas and views of citizens to align to the challenges being addressed by governments")
    area.characteristics.create!(name: "encourage and assist street level workers to take into account the ideas and views of citizens")
  end

  group.focus_areas.create!(name: "Elected government – adaptive community interface") do |area|
    area.save!
    area.characteristics.create!(name: "assist elected members to frame policies in a manner which enables community adaptation of policies")
    area.characteristics.create!(name: "assist elected members to take into account the ideas and views of citizens")
  end
end

FocusAreaGroup.create!(name: "Planned Exploitation of Community Knowledge, Ideas and Innovations") do |group|
  group.save!

  group.focus_areas.create!(name: "Community innovation – public administration interface") do |area|
    area.save!
    area.characteristics.create!(name: "encourage and assist street level workers to exploit the knowledge, ideas and innovations of citizens")
    area.characteristics.create!(name: "bridge community-led activities and projects to the strategic plans of governments")
    area.characteristics.create!(name: "gather, retain and reuse community knowledge and ideas in other contexts")
  end

  group.focus_areas.create!(name: "Community innovation – elected government interface") do |area|
    area.save!
    area.characteristics.create!(name: "encourage and assist elected members to exploit the knowledge, ideas and innovations of citizens")
    area.characteristics.create!(name: "collect, analyse, synthesise, reconfigure, manage and represent community information that is relevant to the electorate or area of portfolio responsibility of elected members")
  end
end
