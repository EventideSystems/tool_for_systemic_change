require 'rails_helper'

RSpec.describe ChecklistItemPolicy do

  let(:account) { create(:account) }
  let(:system_admin_user) { create(:admin_user) }
  let(:account_admin_user) { create(:user, default_account: account, default_account_role: :admin) }
  let(:account_member_user) { create(:user, default_account: account, default_account_role: :member) }
  let(:scorecard) { create(:scorecard, account: account) }
  let(:initiative) { create(:initiative, scorecard: scorecard) }

  subject { described_class }

  permissions ".scope" do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :show? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  permissions :create? do
    pending "add some examples to (or delete) #{__FILE__}"
  end

  [:show?, :update?].each do |action|
    permissions(action) do
      it "grants update if user is a system admin" do
        expect(subject).to permit(UserContext.new(system_admin_user, account), ChecklistItem.new(initiative: initiative))
      end
    
      it "grants update if user is an account admin" do
        expect(subject).to permit(UserContext.new(account_admin_user, account), ChecklistItem.new(initiative: initiative))
      end
    
      it "grants update if user is an account member" do
        expect(subject).to permit(UserContext.new(account_member_user, account), ChecklistItem.new(initiative: initiative))
      end
    end
  end
  
  permissions :destroy? do
    pending "add some examples to (or delete) #{__FILE__}"
  end
end