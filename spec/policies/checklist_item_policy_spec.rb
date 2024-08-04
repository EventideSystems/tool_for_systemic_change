# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(ChecklistItemPolicy) do # rubocop:disable Metrics/BlockLength
  let(:account) { create(:account) }
  let(:system_admin_user) { create(:admin_user) }
  let(:account_admin_user) { create(:user) }
  let(:account_member_user) { create(:user) }
  let(:scorecard) { create(:scorecard, account:) }
  let(:initiative) { create(:initiative, scorecard:) }

  before do
    account.accounts_users.create(user: account_admin_user, account_role: :admin)
    account.accounts_users.create(user: account_member_user, account_role: :member)
  end

  subject { described_class }

  permissions '.scope' do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :show? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  %i[show? update?].each do |action|
    permissions(action) do
      it 'grants update if user is a system admin' do
        expect(subject).to(permit(UserContext.new(system_admin_user, account), ChecklistItem.new(initiative:)))
      end

      it 'grants update if user is an account admin' do
        expect(subject).to(permit(UserContext.new(account_admin_user, account), ChecklistItem.new(initiative:)))
      end

      it 'grants update if user is an account member' do
        expect(subject).to(permit(UserContext.new(account_member_user, account), ChecklistItem.new(initiative:)))
      end
    end
  end

  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
