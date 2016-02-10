class VideoTutorialSerializer < BaseSerializer
  attributes :id, :name, :description, :promote_to_dashboard, :link_url,
    :vimeo_id, :linked_type, :linked_id, :linked_name, :created_at, :updated_at

  belongs_to :linked
end
