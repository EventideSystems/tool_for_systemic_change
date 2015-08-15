json.array!(@wicked_problems) do |wicked_problem|
  json.extract! wicked_problem, :id
  json.url wicked_problem_url(problem, format: :json)
end
