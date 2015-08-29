class BaseSerializer < ActiveModel::Serializer
  def transform_key key
    unless key.to_sym == :json_api_type
      key.to_s.camelize(:lower).to_sym
    else
      key
    end
  end

  # Convert attribute keys to camel case
  # NOTE This may not be required in future version of ActiveModel::Serializers,
  # if support for key_format :lower_camel is introduced as planned.
  # Source from https://github.com/rails-api/active_model_serializers/issues/974
  def attributes *args
    Hash[super.map do |key, value|
      [transform_key(key), value]
    end]
  end

  # Convert relationship keys to camel case
  def each_association &block
    super do |key, association, opts|
      if block_given?
        block.call transform_key(key), association, opts
      end
    end
  end
end
