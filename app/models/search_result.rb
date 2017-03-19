class SearchResult
  attr_accessor :type, :name, :description, :path
  
  def initialize(type, name, description, path)
    @type = type
    @name = name
    @description = description
    @path = path
  end
end