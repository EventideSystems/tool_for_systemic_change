# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ScorecardCopier) do
  subject(:copied) { described_class.new(scorecard, 'new name', deep_copy: deep_copy?).perform }

  let(:user) { create(:user) }
  let(:default_account) { create(:account) }
  let!(:characteristic) { create(:characteristic) }
  let!(:scorecard) { create(:scorecard, account: default_account, initiatives: create_list(:initiative, 2)) }
  let(:initiative) { scorecard.initiatives.first }
  let(:checklist_item) do
    create(:checklist_item, initiative:, characteristic:, user:, comment: 'test', status: :planned)
  end

  before do
    initiative.checklist_items << checklist_item
    initiative.save!
  end

  describe '#copied' do
    let(:deep_copy?) { false }
    let(:copied_first_initiative) { copied.initiatives.where(name: scorecard.initiatives.first.name).first }
    let(:stakeholder_type) { create(:stakeholder_type, account: default_account) }
    let(:organisations) { create_list(:organisation, 5, account: default_account, stakeholder_type:) }

    before do
      scorecard.initiatives.first.organisations = organisations
      scorecard.initiatives.first.save
    end

    it { expect(copied.name).to(eq('new name')) }

    it { expect(copied.description).to(eq(scorecard.description)) }
    it { expect(copied.shared_link_id).not_to(be_blank) }
    it { expect(copied.shared_link_id).not_to(eq(scorecard.shared_link_id)) }

    it { expect(copied.wicked_problem).to(eq(scorecard.wicked_problem)) }
    it { expect(copied.community).to(eq(scorecard.community)) }

    it { expect(copied.initiatives.count).to(eq(scorecard.initiatives.count)) }
    it { expect(copied.initiatives).not_to(eq(scorecard.initiatives)) }

    it do
      copied_first_initiative.reload
      expect(copied_first_initiative.organisations.count).to(eq(5))
    end
  end

  describe '#deep_copied', :run_delayed_jobs do
    let(:deep_copy?) { true }

    let(:copied_first_checklist_item) do
      copied_first_initiative.checklist_items.where(characteristic_id: scorcard_first_checklist_item.characteristic_id).first
    end
    let(:copied_first_initiative) { copied.initiatives.where(name: scorecard.initiatives.first.name).first }
    let(:scorcard_first_checklist_item) { scorcard_first_initiative.checklist_items.first }
    let(:scorcard_first_initiative) { scorecard.initiatives.first }

    it { expect(copied.name).to(eq('new name')) }
    it { expect(copied.description).to(eq(scorecard.description)) }
    it { expect(copied.shared_link_id).not_to(be_blank) }
    it { expect(copied.shared_link_id).not_to(eq(scorecard.shared_link_id)) }

    it { expect(copied.wicked_problem).to(eq(scorecard.wicked_problem)) }
    it { expect(copied.community).to(eq(scorecard.community)) }

    it { expect(copied.initiatives.count).to(eq(scorecard.initiatives.count)) }
    it { expect(copied.initiatives).not_to(eq(scorecard.initiatives)) }

    context 'initiatives' do
      before do
        scorcard_first_checklist_item.status = :actual
        scorcard_first_checklist_item.comment = 'Comment'
        scorcard_first_checklist_item.save!
      end

      it do
        copied.initiatives.reload
        expect(copied_first_checklist_item.comment).to(eq('Comment'))
      end
    end

    context 'history' do
      before do
        scorecard.update(name: 'Updated Name')
      end

      context 'paper trail' do
        let(:original_scorecard_versions) do
          PaperTrail::Version.where(item_type: 'Scorecard', item_id: scorecard.id)
        end

        let(:copied_scorecard_versions) do
          PaperTrail::Version.where(item_type: 'Scorecard', item_id: subject.id)
        end

        it { expect(original_scorecard_versions.count).to(be(2)) }

        it { expect(copied_scorecard_versions.count).to(be(2)) }

        it 'MUST copied all scorecard attributes (other than id and trackable_id)' do
          copied_scorecard_versions.each_with_index do |copied_scorecard_activity, index|
            original_attributes = original_scorecard_versions[index].attributes.delete(%i[id trackable_id])
            copied_attributes = copied_scorecard_activity.attributes.delete(%i[id trackable_id])

            expect(copied_attributes).to(match(original_attributes))
          end
        end
      end
    end
  end
end
