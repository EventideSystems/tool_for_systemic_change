# frozen_string_literal: true

# == Schema Information
#
# Table name: initiatives
#
#  id               :integer          not null, primary key
#  archived_on      :datetime
#  contact_email    :string
#  contact_name     :string
#  contact_phone    :string
#  contact_position :string
#  contact_website  :string
#  dates_confirmed  :boolean
#  deleted_at       :datetime
#  description      :string
#  finished_at      :date
#  linked           :boolean          default(FALSE)
#  name             :string
#  old_notes        :text
#  started_at       :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  scorecard_id     :integer
#
# Indexes
#
#  index_initiatives_on_archived_on   (archived_on)
#  index_initiatives_on_deleted_at    (deleted_at)
#  index_initiatives_on_finished_at   (finished_at)
#  index_initiatives_on_name          (name)
#  index_initiatives_on_scorecard_id  (scorecard_id)
#  index_initiatives_on_started_at    (started_at)
#
require 'rails_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe(Initiative, type: :model) do
  let(:user) { create(:user) }
  let(:default_workspace) { create(:workspace) }
  let(:data_model) { create(:data_model, workspace: default_workspace) }
  let(:focus_area_group) { create(:focus_area_group, data_model:) }
  let(:focus_area) { create(:focus_area, focus_area_group:, position: 1) }

  describe '#checklist_items_ordered_by_ordered_focus_area' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let!(:characteristic_1) { create(:characteristic, focus_area:) } # rubocop:disable RSpec/IndexedLet,RSpec/LetSetup,Naming/VariableNumber
    let!(:characteristic_2) { create(:characteristic, focus_area:) } # rubocop:disable RSpec/IndexedLet,RSpec/LetSetup,Naming/VariableNumber
    let(:stakeholder_type) { create(:stakeholder_type, workspace: default_workspace) }

    let(:scorecard) { create(:scorecard, workspace: default_workspace, data_model:) }

    let!(:initiative) do
      create(:initiative, scorecard:,
                          organisations: create_list(:organisation, 2, workspace: default_workspace, stakeholder_type:))
    end

    describe '.archived?' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      context 'when archived_on is nil' do # rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/NestedGroups
        it 'returns false' do
          expect(initiative).not_to be_archived
        end
      end

      context 'when archived_on is in the future' do # rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/NestedGroups
        before do
          initiative.archived_on = 1.day.from_now
        end

        it 'returns false' do
          expect(initiative).not_to be_archived
        end
      end

      context 'when archived_on is in the past' do # rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/NestedGroups
        before do
          initiative.archived_on = 1.day.ago
        end

        it 'returns true' do
          expect(initiative).to be_archived
        end
      end
    end

    it 'checklist item count equals characteristic count' do
      expect(initiative.checklist_items_ordered_by_ordered_focus_area.count).to(be(2))
    end

    context 'with selected_date' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      it 'retrieves original checklist item state if no changes have occurred' do # rubocop:disable RSpec/MultipleExpectations
        checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(selected_date: Time.zone.today)
        expect(checklist_items[0].status).to eq('no_comment')
        expect(checklist_items[1].status).to eq('no_comment')
      end

      context 'after changes' do # rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/NestedGroups,RSpec/ContextWording
        before do
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(selected_date: Time.zone.today)
          checklist_items.to_a.each { |checklist_item| checklist_item.update(user:, comment: 'test', status: :planned) }
          Timecop.freeze(Time.zone.today + 10)

          checklist_items[1].update!(status: :actual)
          Timecop.return

          Timecop.freeze(Time.zone.today + 20)
          checklist_items[1].update!(status: :more_information)
          Timecop.return
        end

        it 'retrieves previous checklist item state if selected_date is before changes have occurred' do # rubocop:disable RSpec/MultipleExpectations
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(selected_date: Date.yesterday)

          expect(checklist_items[0].status).to(eq('no_comment'))
          expect(checklist_items[1].status).to(eq('no_comment'))
        end

        it 'retrieves updated checklist item state if selected_date is after changes have occurred' do # rubocop:disable RSpec/MultipleExpectations
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(
            selected_date: Time.zone.today + 11
          )

          expect(checklist_items[0].status).to(eq('planned'))
          expect(checklist_items[1].status).to(eq('actual'))
        end

        it 'retrieves updated checklist item state if selected_date is after changes have re-occurred' do # rubocop:disable RSpec/MultipleExpectations
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(
            selected_date: Time.zone.today + 21
          )

          expect(checklist_items[0].status).to(eq('planned'))
          expect(checklist_items[1].status).to(eq('more_information'))
        end
      end
    end

    describe '#copy' do # rubocop:disable RSpec/MultipleMemoizedHelpers
      let(:copy) { initiative.copy }

      it { expect(copy.name).to             eq(initiative.name) }
      it { expect(copy.description).to      eq(initiative.description) }
      it { expect(copy.scorecard_id).to     eq(initiative.scorecard_id) }
      it { expect(copy.started_at).to       eq(initiative.started_at) }
      it { expect(copy.finished_at).to      eq(initiative.finished_at) }
      it { expect(copy.dates_confirmed).to  eq(initiative.dates_confirmed) }
      it { expect(copy.contact_name).to     eq(initiative.contact_name) }
      it { expect(copy.contact_email).to    eq(initiative.contact_email) }
      it { expect(copy.contact_phone).to    eq(initiative.contact_phone) }
      it { expect(copy.contact_website).to  eq(initiative.contact_website) }
      it { expect(copy.contact_position).to eq(initiative.contact_position) }

      context 'with organisations' do # rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/NestedGroups
        it { expect(copy.organisations.count).to eq(2) }
      end

      context 'with checklist items' do # rubocop:disable RSpec/MultipleMemoizedHelpers,RSpec/NestedGroups
        before do
          checklist_items = initiative.checklist_items_ordered_by_ordered_focus_area(selected_date: Time.zone.today)
          checklist_items[0].user = user
          checklist_items[0].status = :planned
          checklist_items[0].comment = 'Comment'
          checklist_items[0].save!
        end

        let(:first_item) do
          copy.checklist_items_ordered_by_ordered_focus_area(selected_date: Time.zone.today).first
        end

        it { expect(copy.checklist_items.count).to eq(2) }
        it { expect(copy.checklist_items.count).to eq(initiative.checklist_items.count) }
        it { expect(first_item.status).to eq('no_comment') }
        it { expect(first_item.comment).to be_nil }
      end
    end
  end

  describe '#create_missing_checklist_items!' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:user) { create(:user) }
    let(:scorecard) { create(:scorecard, workspace: default_workspace, data_model:) }
    let(:initiative) { create(:initiative, scorecard:) }
    let(:characteristic1) { create(:characteristic, focus_area:) } # rubocop:disable RSpec/IndexedLet
    let(:characteristic2) { create(:characteristic, focus_area:) } # rubocop:disable RSpec/IndexedLet
    let(:characteristic3) { create(:characteristic, focus_area:) } # rubocop:disable RSpec/IndexedLet
    let(:comment) { 'test' }
    let(:status) { :planned }

    before do
      # Associate some checklist items with the initiative
      create(:checklist_item, initiative: initiative, characteristic: characteristic1, user:, comment:, status:)
      initiative.reload
    end

    it 'creates missing checklist items for characteristics not yet associated' do # rubocop:disable RSpec/ExampleLength,RSpec/MultipleExpectations
      # Ensure only characteristic2 and characteristic3 are missing
      expect(initiative.checklist_items.map(&:characteristic_id)).to include(characteristic1.id)
      expect(initiative.checklist_items.map(&:characteristic_id)).not_to include(characteristic2.id, characteristic3.id)

      # Call the method
      initiative.create_missing_checklist_items!

      # Reload checklist items and verify all characteristics are now associated
      initiative.reload
      expect(initiative.checklist_items.reload.map(&:characteristic_id)).to include(characteristic1.id, characteristic2.id,
                                                                                    characteristic3.id)
    end

    it 'does not create duplicate checklist items for already associated characteristics' do
      # Call the method twice
      initiative.create_missing_checklist_items!
      expect { initiative.create_missing_checklist_items! }.not_to(change { initiative.reload.checklist_items.count })
    end

    it 'does nothing if all characteristics are already associated' do
      # Associate all characteristics
      create(:checklist_item, initiative:, characteristic: characteristic2, user:, comment:, status:)
      create(:checklist_item, initiative:, characteristic: characteristic3, user:, comment:, status:)

      # Call the method
      expect { initiative.create_missing_checklist_items! }.not_to(change { initiative.checklist_items.count })
    end
  end
end
# rubocop:enable Metrics/BlockLength
