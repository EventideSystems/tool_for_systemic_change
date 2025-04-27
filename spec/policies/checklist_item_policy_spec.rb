# frozen_string_literal: true

require 'rails_helper'
require 'shared/workspace_context'

RSpec.describe(ChecklistItemPolicy) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  include_context 'with simple workspace'

  let(:policy) { described_class }
  let(:workspace_admin_user) { create(:user) }
  let(:system_admin_user) { create(:user, :admin) }
  let(:workspace_member_user) { create(:user) }

  let(:scorecard) { create(:scorecard, workspace:, data_model:) }
  let(:initiative) { create(:initiative, scorecard:) }

  before do
    workspace.workspaces_users.create(user: workspace_admin_user, workspace_role: :admin)
    workspace.workspaces_users.create(user: workspace_member_user, workspace_role: :member)
  end

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
      it "grants #{action} if user is a system admin" do
        expect(policy).to(permit(UserContext.new(system_admin_user, workspace), ChecklistItem.new(initiative:)))
      end

      it "grants #{action} if user is an workspace admin" do
        expect(policy).to(permit(UserContext.new(workspace_admin_user, workspace), ChecklistItem.new(initiative:)))
      end

      it "grants #{action} if user is an workspace member" do
        expect(policy).to(permit(UserContext.new(workspace_member_user, workspace), ChecklistItem.new(initiative:)))
      end
    end
  end

  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end
