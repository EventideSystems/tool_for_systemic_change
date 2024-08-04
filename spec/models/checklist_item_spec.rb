# frozen_string_literal: true

# == Schema Information
#
# Table name: checklist_items
#
#  id                         :integer          not null, primary key
#  checked                    :boolean
#  comment                    :text
#  deleted_at                 :datetime
#  status                     :string           default("no_comment")
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  characteristic_id          :integer
#  initiative_id              :integer
#  previous_characteristic_id :bigint
#  user_id                    :bigint
#
# Indexes
#
#  index_checklist_items_on_characteristic_id  (characteristic_id)
#  index_checklist_items_on_deleted_at         (deleted_at)
#  index_checklist_items_on_initiative_id      (initiative_id)
#  index_checklist_items_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (previous_characteristic_id => characteristics.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe(ChecklistItem) do # rubocop:disable Metrics/BlockLength
  let(:user) { create(:user) }
  let(:characteristic) { create(:characteristic) }
  let(:initiative) { create(:initiative) }
  let(:checklist_item) do
    create(:checklist_item, initiative:, characteristic:, user:, comment: 'test', status: :planned)
  end

  before { initiative.checklist_items << checklist_item }

  subject { checklist_item }

  describe '#snapshot_at' do
    context 'without changes' do
      it { expect(subject.snapshot_at(Time.now)).to(eq(subject)) }
    end

    context 'with changes' do
      before do
        Timecop.freeze(Date.today + 10.days)
        subject.update(status: :actual)
        Timecop.return

        Timecop.freeze(Date.today + 20.days)
        subject.update(status: :more_information)
        Timecop.return
      end

      it 'expects original status to be planned' do
        expect(subject.snapshot_at(Time.now).status).to(eq('planned'))
      end

      it 'expects first checked state to be true' do
        expect(subject.snapshot_at(Date.today + 11).status).to(eq('actual'))
      end
      it 'expects first checked state to be true' do
        expect(subject.snapshot_at(Date.today + 21).status).to(eq('more_information'))
      end
    end
  end
end
