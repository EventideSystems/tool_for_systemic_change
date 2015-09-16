class ChecklistItemSerializer < BaseSerializer
  attributes :id, :checked, :comment

  belongs_to :initiative
  belongs_to :characteristic

end
