# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Accounts::Copy, type: :service) do
  let(:account) { create(:account) }
  let(:new_name) { "#{account.name} (copy)" }

  before do
    # Create some stakeholder types and focus area groups for the account
    create_list(:stakeholder_type, 3, account:)
    create_list(:focus_area_group, 2, account:)
  end

  describe '.call' do
    subject { described_class.call(account:, new_name:) }

    it 'creates a new account with the specified name' do
      expect { subject }.to(change { Account.count }.by(1))
      new_account = Account.last
      expect(new_account.name).to(eq(new_name))
    end

    it 'copies stakeholder types to the new account' do
      subject
      new_account = Account.last
      expect(new_account.stakeholder_types.count).to(eq(account.stakeholder_types.count))
      new_account.stakeholder_types.each do |new_stakeholder_type|
        expect(account.stakeholder_types.pluck(:name)).to(include(new_stakeholder_type.name))
      end
    end

    it 'copies focus area groups to the new account' do
      subject
      new_account = Account.last
      expect(new_account.focus_area_groups.count).to(eq(account.focus_area_groups.count))
      new_account.focus_area_groups.each do |new_focus_area_group|
        expect(account.focus_area_groups.pluck(:name)).to(include(new_focus_area_group.name))
      end
    end
  end
end
