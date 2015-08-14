# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Sector.delete_all

Sector.create(name: 'Local government')
Sector.create(name: 'State government')
Sector.create(name: 'Federal government')
Sector.create(name: 'Education')
Sector.create(name: 'Education')

Problem.delete_all

Problem.create(name: "Climate change")
Problem.create(name: "Obesity")
Problem.create(name: "Indigenous disadvantage")

Model::FocusAreaGroup.delete_all
Model::FocusArea.delete_all
Model::InterventionCharacteristic.delete_all

Model::FocusAreaGroup.create(name: "Unlock Complex Adaptive System Dynamics") do |group|
  group.save!
  group.focus_areas.create(name: "Create a disequilibrium state") do |area|
    area.save!
    area.intervention_characteristics.create(name: "highlight the need to organise communities differently")
    area.intervention_characteristics.create(name: "cultivate a passion for action")
    area.intervention_characteristics.create(name: "manage initial starting conditions")
    area.intervention_characteristics.create(name: "specify goals in advance")
    area.intervention_characteristics.create(name: "establish appropriate boundaries")
    area.intervention_characteristics.create(name: "embrace uncertainty")
    area.intervention_characteristics.create(name: "surface conflict")
    area.intervention_characteristics.create(name: "create controversy")
  end

  group.focus_areas.create(name: "Amplify action") do |area|
    area.save!
    area.intervention_characteristics.create(name: "enable safe fail experimentation")
    area.intervention_characteristics.create(name: "enable rich interactions in relational spaces")
    area.intervention_characteristics.create(name: "support collective action")
    area.intervention_characteristics.create(name: "partition the system")
    area.intervention_characteristics.create(name: "establish network linkages")
    area.intervention_characteristics.create(name: "frame issues to match diverse perspectives")
  end

  group.focus_areas.create(name: "Encourage self-organisation") do |area|
    area.save!
    area.intervention_characteristics.create(name: "create correlation through language and symbols")
    area.intervention_characteristics.create(name: "encourage individuals to accept positions as role models for the change effort")
    area.intervention_characteristics.create(name: "enable periodic information exchanges between partitioned subsystems")
    area.intervention_characteristics.create(name: "enable resources and capabilities to recombine")
  end

  group.focus_areas.create(name: "Stabilise feedback") do |area|
    area.save!
    area.intervention_characteristics.create(name: "integrate local constraints")
    area.intervention_characteristics.create(name: "provide a multiple perspective context and system structure")
    area.intervention_characteristics.create(name: "enable problem representations to anchor in the community")
    area.intervention_characteristics.create(name: "enable emergent outcomes to be monitored")
  end

  group.focus_areas.create(name: "Enable information flows") do |area|
    area.save!
    area.intervention_characteristics.create(name: "assist system members to keep informed and knowledgeable of forces influencing their community system")
    area.intervention_characteristics.create(name: "assist in the connection, dissemination and processing of information")
    area.intervention_characteristics.create(name: "enable connectivity between people who have different perspectives on community issues")
    area.intervention_characteristics.create(name: "retain and reuse knowledge and ideas generated through interactions")
  end
end

Model::FocusAreaGroup.create(name: "Unplanned Exploration of Solutions with Communities") do |group|
  group.save!
  group.focus_areas.create(name: "Public administration – adaptive community interface") do |area|
    area.save!
    area.intervention_characteristics.create(name: "assist public administrators to frame policies in a manner which enables community adaptation of policies")
    area.intervention_characteristics.create(name: "remove information differences to enable the ideas and views of citizens to align to the challenges being addressed by governments")
    area.intervention_characteristics.create(name: "encourage and assist street level workers to take into account the ideas and views of citizens")
  end

  group.focus_areas.create(name: "Elected government – adaptive community interface") do |area|
    area.save!
    area.intervention_characteristics.create(name: "assist elected members to frame policies in a manner which enables community adaptation of policies")
    area.intervention_characteristics.create(name: "assist elected members to take into account the ideas and views of citizens")
  end
end

Model::FocusAreaGroup.create(name: "Planned Exploitation of Community Knowledge, Ideas and Innovations") do |group|
  group.save!

  group.focus_areas.create(name: "Community innovation – public administration interface") do |area|
    area.save!
    area.intervention_characteristics.create(name: "encourage and assist street level workers to exploit the knowledge, ideas and innovations of citizens")
    area.intervention_characteristics.create(name: "bridge community-led activities and projects to the strategic plans of governments")
    area.intervention_characteristics.create(name: "gather, retain and reuse community knowledge and ideas in other contexts")
  end

  group.focus_areas.create(name: "Community innovation – elected government interface") do |area|
    area.save!
    area.intervention_characteristics.create(name: "encourage and assist elected members to exploit the knowledge, ideas and innovations of citizens")
    area.intervention_characteristics.create(name: "collect, analyse, synthesise, reconfigure, manage and represent community information that is relevant to the electorate or area of portfolio responsibility of elected members")
  end
end
