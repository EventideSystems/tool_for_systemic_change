class InitiativeChecklistItemSerializer < BaseSerializer
  attributes :id, :checked, :comment

  belongs_to :initiative
  belongs_to :initiative_characteristic

end
