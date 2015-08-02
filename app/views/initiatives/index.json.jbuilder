json.array!(@initiatives) do |initiative|
  json.extract! initiative, :id
  json.url initiative_url(initiative, format: :json)
end
