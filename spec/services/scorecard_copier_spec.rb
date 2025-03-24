# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ScorecardCopier) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  subject(:copied) { described_class.new(scorecard, 'new name', deep_copy: deep_copy?).perform }

  let(:user) { create(:user) }
  let(:default_workspace) { create(:workspace) }
  let!(:characteristic) { create(:characteristic) }
  let!(:scorecard) { create(:scorecard, workspace: default_workspace, initiatives: create_list(:initiative, 2)) }
  let(:initiative) { scorecard.initiatives.first }
  let(:checklist_item) do
    create(:checklist_item, initiative:, characteristic:, user:, comment: 'test', status: :planned)
  end

  before do
    initiative.checklist_items << checklist_item
    initiative.save!
  end

  describe '#copied' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:deep_copy?) { false }
    let(:copied_first_initiative) { copied.initiatives.where(name: scorecard.initiatives.first.name).first }
    let(:stakeholder_type) { create(:stakeholder_type, workspace: default_workspace) }
    let(:organisations) { create_list(:organisation, 5, workspace: default_workspace, stakeholder_type:) }

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
end
