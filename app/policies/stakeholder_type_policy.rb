# frozen_string_literal: true

# Policy for StakeholderType, extends LabelPolicy but blcocks deletion if the StakeholderType
# is still associated with any organisations
class StakeholderTypePolicy < LabelPolicy
  def destroy?
    record.organisations.empty? && super
  end
end
