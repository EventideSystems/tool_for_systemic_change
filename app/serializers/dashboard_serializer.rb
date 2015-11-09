class DashboardSerializer < BaseSerializer
  attributes :welcome_message_html, :client_name, :activities

  def activities
    object.activities
  end
end
