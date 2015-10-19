# TODO Prevent this from deleting production data. Ideally should be idempotent

FocusAreaGroup.delete_all
FocusArea.delete_all
Characteristic.delete_all

# SMELL Not in use!
def create_focus_area_group(name)
  group = FocusAreaGroup.find_or_create!(name: name)

  yield group

end

FocusAreaGroup.create!(name: "Unlock Complex Adaptive System Dynamics", position: 1) do |group|
  group.save!
  group.focus_areas.create!(name: "create! a disequilibrium state", position: 1) do |area|
    area.save!
    area.characteristics.create!(name: "highlight the need to organise communities differently", position: 1)
    area.characteristics.create!(name: "cultivate a passion for action", position: 2)
    area.characteristics.create!(name: "manage initial starting conditions", position: 3)
    area.characteristics.create!(name: "specify goals in advance", position: 4)
    area.characteristics.create!(name: "establish appropriate boundaries", position: 5)
    area.characteristics.create!(name: "embrace uncertainty", position: 6)
    area.characteristics.create!(name: "surface conflict", position: 7)
    area.characteristics.create!(name: "create! controversy", position: 8)
  end

  group.focus_areas.create!(name: "Amplify action", position: 2) do |area|
    area.save!
    area.characteristics.create!(name: "enable safe fail experimentation", position: 1)
    area.characteristics.create!(name: "enable rich interactions in relational spaces", position: 2)
    area.characteristics.create!(name: "support collective action", position: 3)
    area.characteristics.create!(name: "partition the system", position: 4)
    area.characteristics.create!(name: "establish network linkages", position: 5)
    area.characteristics.create!(name: "frame issues to match diverse perspectives", position: 6)
  end

  group.focus_areas.create!(name: "Encourage self-organisation", position: 3) do |area|
    area.save!
    area.characteristics.create!(name: "create! correlation through language and symbols", position: 1)
    area.characteristics.create!(name: "encourage individuals to accept positions as role models for the change effort", position: 2)
    area.characteristics.create!(name: "enable periodic information exchanges between partitioned subsystems", position: 3)
    area.characteristics.create!(name: "enable resources and capabilities to recombine", position: 4)
  end

  group.focus_areas.create!(name: "Stabilise feedback", position: 4) do |area|
    area.save!
    area.characteristics.create!(name: "integrate local constraints", position: 1)
    area.characteristics.create!(name: "provide a multiple perspective context and system structure", position: 2)
    area.characteristics.create!(name: "enable problem representations to anchor in the community", position: 3)
    area.characteristics.create!(name: "enable emergent outcomes to be monitored", position: 4)
  end

  group.focus_areas.create!(name: "Enable information flows", position: 5) do |area|
    area.save!
    area.characteristics.create!(name: "assist system members to keep informed and knowledgeable of forces influencing their community system", position: 1)
    area.characteristics.create!(name: "assist in the connection, dissemination and processing of information", position: 2)
    area.characteristics.create!(name: "enable connectivity between people who have different perspectives on community issues", position: 3)
    area.characteristics.create!(name: "retain and reuse knowledge and ideas generated through interactions", position: 4)
  end
end

FocusAreaGroup.create!(name: "Unplanned Exploration of Solutions with Communities", position: 2) do |group|
  group.save!
  group.focus_areas.create!(name: "Public administration – adaptive community interface", position: 1) do |area|
    area.save!
    area.characteristics.create!(name: "assist public administrators to frame policies in a manner which enables community adaptation of policies", position: 1)
    area.characteristics.create!(name: "remove information differences to enable the ideas and views of citizens to align to the challenges being addressed by governments", position: 2)
    area.characteristics.create!(name: "encourage and assist street level workers to take into account the ideas and views of citizens", position: 3)
  end

  group.focus_areas.create!(name: "Elected government – adaptive community interface", position: 2) do |area|
    area.save!
    area.characteristics.create!(name: "assist elected members to frame policies in a manner which enables community adaptation of policies", position: 1)
    area.characteristics.create!(name: "assist elected members to take into account the ideas and views of citizens", position: 2)
  end
end

FocusAreaGroup.create!(name: "Planned Exploitation of Community Knowledge, Ideas and Innovations", position: 3) do |group|
  group.save!

  group.focus_areas.create!(name: "Community innovation – public administration interface", position: 1) do |area|
    area.save!
    area.characteristics.create!(name: "encourage and assist street level workers to exploit the knowledge, ideas and innovations of citizens", position: 1)
    area.characteristics.create!(name: "bridge community-led activities and projects to the strategic plans of governments", position: 2)
    area.characteristics.create!(name: "gather, retain and reuse community knowledge and ideas in other contexts", position: 3)
  end

  group.focus_areas.create!(name: "Community innovation – elected government interface", position: 2) do |area|
    area.save!
    area.characteristics.create!(name: "encourage and assist elected members to exploit the knowledge, ideas and innovations of citizens", position: 1)
    area.characteristics.create!(name: "collect, analyse, synthesise, reconfigure, manage and represent community information that is relevant to the electorate or area of portfolio responsibility of elected members", position: 2)
  end
end
