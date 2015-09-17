class Profile
  attr_reader :user_email
  attr_reader :user_role
  attr_reader :user_name
  attr_reader :client_name

  def initialize(user)
    @user_email = user.email
    @user_role = user.role
    @user_name = user.name
    @client_name = if user.staff?
      ''
    else
      user.client.name
    end
  end

  def id
    nil
  end

  # NOTE fake just enough of the interface expected of
  # ActiveModel::Serializers. See:
  # https://github.com/rails-api/active_model_serializers/blob/master/test/fixtures/poro.rb

  def read_attribute_for_serialization(name)
    send(name)
  end

  def self.model_name
    ActiveModel::Name.new(self)
  end
end
