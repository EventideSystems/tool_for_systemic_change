# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ImpactCards::DeepMerge, type: :service) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:user) { create(:user) }
  let(:account) { create(:account) }

  let(:stakeholder_type) { create(:stakeholder_type, account:) }
  let(:organisation) { create(:organisation, account:, stakeholder_type:) }
  let(:other_organisation) { create(:organisation, account:, stakeholder_type:) }

  let(:subsystem_tag) { create(:subsystem_tag, account:) }
  let(:other_subsystem_tag) { create(:subsystem_tag, account:) }

  let(:impact_card) { create(:scorecard, account:) }
  let(:other_impact_card) { create(:scorecard, account:) }

  let!(:clashing_initiative) do
    create(
      :initiative,
      name: 'Clashing Initiative',
      scorecard: impact_card,
      started_at: nil,
      finished_at: 12.days.from_now,
      updated_at: 2.days.ago
    )
  end

  let!(:other_clashing_initiative) do
    create(
      :initiative,
      name: 'Clashing Initiative',
      scorecard: other_impact_card,
      started_at: 11.days.ago,
      finished_at: 14.days.from_now,
      updated_at: 1.day.ago
    )
  end

  let!(:non_clashing_initiative) do
    create(:initiative, name: 'Non-Clashing Initiative', scorecard: other_impact_card)
  end

  let(:characteristic) { create(:characteristic, name: 'Checklist Item 1') }

  let!(:checklist_item) do
    create(:checklist_item, characteristic:, user:, initiative: clashing_initiative, comment: 'Comment')
  end

  let!(:checklist_item_change) do
    create(
      :checklist_item_change,
      checklist_item:,
      user:,
      starting_status: :planned,
      ending_status: :actual,
      action: :update_existing,
      activity: :addition,
      comment: 'Comment',
      created_at: 3.days.ago
    )
  end

  let!(:other_checklist_item) do
    create(:checklist_item, characteristic:, user:, initiative: other_clashing_initiative, comment: 'Other Comment')
  end

  let!(:other_checklist_item_change) do
    create(
      :checklist_item_change,
      checklist_item: other_checklist_item,
      user:,
      starting_status: :planned,
      ending_status: :actual,
      action: :update_existing,
      activity: :addition,
      comment: 'Other Comment',
      created_at: 2.days.ago
    )
  end

  let(:non_clashing_checklist_item) do
    create(
      :checklist_item,
      characteristic:,
      user:,
      initiative: non_clashing_initiative,
      comment: 'Non-Clashing Comment'
    )
  end

  let(:service) { described_class.new(impact_card:, other_impact_card:) }

  before do
    non_clashing_checklist_item # Create non-clashing checklist item

    clashing_initiative.organisations << [organisation]
    clashing_initiative.subsystem_tags << [subsystem_tag]
    clashing_initiative.save!

    other_clashing_initiative.organisations << [organisation, other_organisation]
    other_clashing_initiative.subsystem_tags << [subsystem_tag, other_subsystem_tag]
    other_clashing_initiative.save!
  end

  describe 'merging clashing initiatives' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    it 'merges clashing initiatives' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      service.call

      clashing_initiative.reload
      clashing_initiative.checklist_items.reload
      other_checklist_item_change.reload

      expect(impact_card.initiatives.where(name: 'Clashing Initiative').count).to(eq(1))

      expect(clashing_initiative.started_at).to(eq(11.days.ago.to_date))
      expect(clashing_initiative.finished_at).to(eq(14.days.from_now.to_date))

      expect(clashing_initiative.checklist_items.count).to(eq(1))
      expect(clashing_initiative.checklist_items.first.name).to(eq('Checklist Item 1'))
      expect(clashing_initiative.checklist_items.first.status).to(eq('actual'))
      expect(clashing_initiative.checklist_items.first.comment).to(eq('Other Comment'))
      expect(clashing_initiative.checklist_items.first.checklist_item_changes.count).to(eq(2))

      expect(checklist_item_change.starting_status).to(eq('planned'))
      expect(checklist_item_change.activity).to(eq('addition'))

      expect(other_checklist_item_change.checklist_item).to(eq(clashing_initiative.checklist_items.first))
      expect(other_checklist_item_change.starting_status).to(eq('actual'))
      expect(other_checklist_item_change.activity).to(eq('none'))

      expect(clashing_initiative.organisations).to(eq([organisation, other_organisation]))

      expect(clashing_initiative.subsystem_tags).to(eq([subsystem_tag, other_subsystem_tag]))
    end

    it 'preserves contact information regardless of the update order of the initiatives' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      clashing_initiative.update!(
        contact_name: 'Contact Name',
        contact_email: 'Contact Email',
        contact_phone: 'Contact Phone',
        contact_website: 'Contact Website',
        contact_position: 'Contact Position'
      )

      other_clashing_initiative.update!(
        contact_name: nil,
        contact_email: nil,
        contact_phone: nil,
        contact_website: nil,
        contact_position: nil
      )

      service.call

      clashing_initiative.reload

      expect(clashing_initiative.contact_name).to(eq('Contact Name'))
      expect(clashing_initiative.contact_email).to(eq('Contact Email'))
      expect(clashing_initiative.contact_phone).to(eq('Contact Phone'))
      expect(clashing_initiative.contact_website).to(eq('Contact Website'))
      expect(clashing_initiative.contact_position).to(eq('Contact Position'))
    end
  end

  describe 'merging "new_comments_saved_assigned_actuals" when previous change ended as "actual"' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let!(:additional_other_checklist_item_change) do
      create(
        :checklist_item_change,
        checklist_item: other_checklist_item,
        user:,
        starting_status: :actual,
        ending_status: :actual,
        action: :save_new_comment,
        activity: :new_comments_saved_assigned_actuals,
        comment: 'Final Comment',
        created_at: 1.day.ago
      )
    end

    it 'maintains "new_comments_saved_assigned_actuals" activity' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      service.call

      clashing_initiative.checklist_items.reload
      additional_other_checklist_item_change.reload

      expect(additional_other_checklist_item_change.activity).to(eq('new_comments_saved_assigned_actuals'))
      expect(clashing_initiative.checklist_items.first.status).to(eq('actual'))
      expect(clashing_initiative.checklist_items.first.comment).to(eq('Final Comment'))
    end
  end

  describe 'merging "new_comments_saved_assigned_actuals" when previous change ended as "planned"' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let!(:other_checklist_item_change) do # rubocop:disable RSpec/LetSetup
      create(
        :checklist_item_change,
        checklist_item: other_checklist_item,
        user:,
        starting_status: :no_comment,
        ending_status: :planned,
        action: :save_new_comment,
        activity: :none,
        comment: 'Other Comment',
        created_at: 2.days.ago
      )
    end

    let!(:additional_other_checklist_item_change) do
      create(
        :checklist_item_change,
        checklist_item: other_checklist_item,
        user:,
        starting_status: :actual,
        ending_status: :actual,
        action: :save_new_comment,
        activity: :new_comments_saved_assigned_actuals,
        comment: 'Final Comment',
        created_at: 1.day.ago
      )
    end

    it 'maintains "new_comments_saved_assigned_actuals" activity' do
      service.call

      additional_other_checklist_item_change.reload

      expect(additional_other_checklist_item_change.activity).to(eq('addition'))
    end
  end

  describe 'merging non clashing initiatives' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    it 'retargets non-clashing initiatives to the impact card' do # rubocop:disable RSpec/MultipleExpectations
      service.call

      expect(impact_card.initiatives.pluck(:name)).to(include('Non-Clashing Initiative'))
      expect(other_impact_card.initiatives.pluck(:name)).not_to(include('Non-Clashing Initiative'))
    end
  end
end
