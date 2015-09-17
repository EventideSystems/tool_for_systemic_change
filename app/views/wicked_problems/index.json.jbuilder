json.array!(@wicked_problems) do |wicked_problem|
  json.type 'wicked_problems'
  json.id wicked_problem.id
  json.attributes do
    json.extract! wicked_problem, :name, :description, :created_at, :updated_at
  end
  json.links do
    json.client do
      json.id wicked_problem.client.id
    end
  end
end

