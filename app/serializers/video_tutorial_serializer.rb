class VideoTutorialSerializer < BaseSerializer
  attributes :id, :name, :description, :promote_to_dashboard, :link_url, :vimeo_id, :created_at, :updated_at

  belongs_to :linked
end
