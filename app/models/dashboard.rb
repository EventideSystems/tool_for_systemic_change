require 'redcarpet'

class Dashboard
  include ActiveModel::Model
  include ActiveModel::Serialization

  attr_reader :welcome_message
  attr_reader :client_name
  attr_reader :activities

  def initialize(client)
    @client_name = client.name
    @welcome_message = client.welcome_message

    @activities = PublicActivity::Activity.
      where(client_id: client.id).
      order(created_at: :desc).limit(10).all
  end

  def id
    nil
  end

  def welcome_message_html
    return '' if welcome_message.blank?

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)

    markdown.render(welcome_message)
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
