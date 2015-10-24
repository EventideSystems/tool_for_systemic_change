class ChecklistItemSerializer < BaseSerializer
  attributes :id, :checked, :comment, :created_at, :updated_at

  belongs_to :initiative
  belongs_to :characteristic

end
