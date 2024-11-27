# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ImpactCards::DeepCopy, type: :service do
  let(:account) { create(:account) }
  let(:target_account) { create(:account) }
  let(:impact_card) { create(:scorecard, account: account, type: 'TransitionCard') }
  let(:new_name) { "#{impact_card.name} (copy)" }
  let(:subsystem_tags) { create_list(:subsystem_tag, 3, account: account) }
  let(:initiatives) { create_list(:initiative, 2, scorecard: impact_card) }
  let(:stakeholder_types) { create_list(:stakeholder_type, 4, account: account) }
  let(:stakeholders) do
    stakeholder_types.each_with_object([]) do |stakeholder_type, memo|
      memo << create(:organisation, account:, stakeholder_type:)
    end
  end
  let(:user) { create(:user) }

  let(:focus_area_groups) { create_list(:focus_area_group, 2, account: account, scorecard_type: 'TransitionCard') }
  let(:focus_areas) { create_list(:focus_area, 2, focus_area_group: focus_area_groups.first) }
  let(:characteristics) { create_list(:characteristic, 2, focus_area: focus_areas.first) }

  let(:new_impact_card) { Scorecard.last } # This should be the new impact card created by the service

  before do
    focus_area_groups
    focus_areas
    characteristics

    focus_area_groups.each do |focus_area_group|
      focus_area_group.dup.tap do |new_group|
        new_group.account = target_account
        new_group.save!

        focus_area_group.focus_areas.each do |focus_area|
          focus_area.dup.tap do |new_area|
            new_area.focus_area_group = new_group
            new_area.save!

            focus_area.characteristics.each do |characteristic|
              characteristic.dup.tap do |new_characteristic|
                new_characteristic.focus_area = new_area
                new_characteristic.save!
              end
            end
          end
        end
      end
    end

    impact_card

    initiatives.first.reload.tap do |initiative|
      initiative.subsystem_tags << subsystem_tags[0..1]
      initiative.organisations << stakeholders[0..1]

      initiative.checklist_items.first.reload.tap do |checklist_item|
        checklist_item.checklist_item_changes.create(
          user: user,
          action: 'update_existing',
          activity: 'none',
          starting_status: 'planned',
          comment: 'This is the initial comment',
          ending_status: 'planned'
        )

        checklist_item.checklist_item_changes.create(
          user: user,
          action: 'update_existing',
          activity: 'new_comments_saved_assigned_actuals',
          comment: 'This is the updated comment',
          starting_status: 'planned',
          ending_status: 'actual'
        )

        checklist_item.update!(user:, status: 'actual', comment: 'This is the updated comment')
      end

      initiative.save!
    end

    initiatives.second.tap do |initiative|
      initiative.subsystem_tags << subsystem_tags[1..2]
      initiative.organisations << stakeholders[0..3]
      initiative.save!
    end

  end

  describe '.call' do
    subject { described_class.call(impact_card: impact_card, new_name: new_name, target_account: target_account) }

    it 'creates a new impact card with the specified name' do
      expect { subject }.to change { Scorecard.count }.by(1)
      new_impact_card = Scorecard.last
      expect(new_impact_card.name).to eq(new_name)
      expect(new_impact_card.account).to eq(target_account)
    end

    it 'copies subsystem tags to the target account' do
      expect { subject }.to change { target_account.subsystem_tags.count }.by(3)
    end

    it 'copies subsystem tags to the new impact card' do
      subject
      new_impact_card = Scorecard.last
      expect(new_impact_card.subsystem_tags.count).to eq(impact_card.subsystem_tags.count)
      new_impact_card.subsystem_tags.each do |new_subsystem_tag|
        expect(impact_card.subsystem_tags.pluck(:name)).to include(new_subsystem_tag.name)
      end
    end

    it 'copies stakeholder types to the target account' do
      expect { subject }.to change { target_account.stakeholder_types.count }.by(4)
    end

    it 'copies stakeholders to the target account' do
      expect { subject }.to change { target_account.organisations.count }.by(4)
    end

    it 'copies stakeholders to the new impact card' do
      subject
      new_impact_card = Scorecard.last
      expect(new_impact_card.organisations.count).to eq(impact_card.organisations.count)
      new_impact_card.organisations.each do |new_stakeholder|
        expect(impact_card.organisations.pluck(:name)).to include(new_stakeholder.name)
      end
    end

    it 'copies initiatives to the new impact card' do
      subject
      new_impact_card = Scorecard.last
      expect(new_impact_card.initiatives.count).to eq(impact_card.initiatives.count)
      new_impact_card.initiatives.each do |new_initiative|
        expect(impact_card.initiatives.pluck(:name)).to include(new_initiative.name)
      end
    end

    describe 'checklist items' do
      let(:source_checklist_item) {  initiatives.first.checklist_items.first }
      let(:target_checklist_item) do
        new_impact_card
          .initiatives
          .find { |initiative| initiative.name == initiatives.first.name }
          .checklist_items.find { |item| item.characteristic.name == source_checklist_item.characteristic.name }
      end

      let(:first_change) { target_checklist_item.checklist_item_changes.first }
      let(:second_change) { target_checklist_item.checklist_item_changes.second }

      it 'copies checklist item status and comments to the new impact card' do
        subject

        expect(target_checklist_item.status).to eq('actual')
        expect(target_checklist_item.comment).to eq('This is the updated comment')
        expect(target_checklist_item.updated_at).to eq(source_checklist_item.updated_at)
      end

      it 'copies checklist item changes to the new impact card' do
        subject

        expect(target_checklist_item.checklist_item_changes.count).to eq(2)

        expect(first_change.user).to eq(user)
        expect(first_change.starting_status).to eq('planned')
        expect(first_change.ending_status).to eq('planned')
        expect(first_change.comment).to eq('This is the initial comment')
        expect(first_change.action).to eq('update_existing')
        expect(first_change.activity).to eq('none')
        expect(first_change.created_at).to eq(source_checklist_item.checklist_item_changes.first.created_at)

        expect(second_change.user).to eq(user)
        expect(second_change.starting_status).to eq('planned')
        expect(second_change.ending_status).to eq('actual')
        expect(second_change.comment).to eq('This is the updated comment')
        expect(second_change.action).to eq('update_existing')
        expect(second_change.activity).to eq('new_comments_saved_assigned_actuals')
        expect(second_change.created_at).to eq(source_checklist_item.checklist_item_changes.second.created_at)
      end
    end
  end
end
