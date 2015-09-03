module DeserializeJsonApi
  extend ActiveSupport::Concern

  def normalize(params)
    return params['attributes'] unless params['relationships']

    relationships = params['relationships'].reduce({}) do |memo, assoc|
      if assoc.last['data'].is_a? Array
        memo["#{assoc.first}_ids"] = assoc.last['data'].map do |record|
          record['id']
        end
      elsif assoc.last['data'].is_a? Hash
        memo["#{assoc.first}_id"] = assoc.last['data']['id']
      end

      memo
    end

    (params['attributes'] || ActionController::Parameters.new).merge(relationships)
  end

  IncludedParam = Struct.new(:type, :attributes)

  def normalize_included(params)
    return [] if params.nil?

    included = params.reduce([]) do |memo, included_params|
      type = included_params['type'].singularize.to_sym
      memo << IncludedParam.new(type, normalize(included_params))
    end

    included
  end

end

# {
#   type: 'wicked_problems',
#   attributes: {
#     name: wicked_problem_name,
#     description: wicked_problem_description,
#   },
#   relationships: {
#     community: { data: { id: community.id } },
#     administrating_organisation: { data: { id: administrating_organisation.id } }
#   }
# }
