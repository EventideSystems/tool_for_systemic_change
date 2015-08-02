json.array!(@problems) do |problem|
  json.extract! problem, :id
  json.url problem_url(problem, format: :json)
end
