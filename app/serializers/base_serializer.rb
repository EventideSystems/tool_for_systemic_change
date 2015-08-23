class BaseSerializer < ActiveModel::Serializer
  def transform_key key
    unless key.to_sym == :json_api_type
      key.to_s.camelize(:lower).to_sym
    else
      key
    end
  end

  def attributes *args
    Hash[super.map do |key, value|
      [transform_key(key), value]
    end]
  end

  def each_association &block
    super do |key, association, opts|
      if block_given?
        block.call transform_key(key), association, opts
      end
    end
  end
end
