module FlattenParams
  extend ActiveSupport::Concern

  def flatten_params(params)
    attributes = params[:attributes] ||= {}

    if params[:relationships]
      params[:relationships].each do |relationship|
        base_name = relationship.first
        base_data = relationship.second[:data]

        if base_data.is_a?(Hash)
          attributes.merge!("#{base_name}_id".to_sym => base_data[:id].to_i)
        elsif base_data.is_a?(Array)
          attributes.merge!("#{base_name}_ids".to_sym => base_data.map{ |data| data[:id].to_i } )
        else
          raise "Unprocessable data type '#{data.class}'"
        end
      end
    end
    attributes
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
