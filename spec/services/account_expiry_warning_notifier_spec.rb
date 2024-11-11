# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(AccountExpiryWarningNotifier) do
  let(:account) { create(:account, expires_on: expires_on, expiry_warning_sent_on: expiry_warning_sent_on) }
  let(:user) { create(:user) }
  let(:mailer) { double(:mailer) } # rubocop:disable RSpec/VerifiedDoubles
  let(:service_call) { described_class.call }

  before do
    AccountsUser.create(account: account, user: user, account_role: :member)
  end

  context 'when previously warned account has been renewed' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:expires_on) { 31.days.from_now }
    let(:expiry_warning_sent_on) { 31.days.from_now }

    it 'updates the expiry_warning to no_warning' do
      expect { service_call }
        .to(change { account.reload.expiry_warning_sent_on }
        .to(nil))
    end
  end

  context 'when account expires more than 30 days from now' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:expires_on) { 31.days.from_now }
    let(:expiry_warning_sent_on) { nil }

    it 'does not send an email' do # rubocop:disable RSpec/MultipleExpectations
      expect(AccountMailer).not_to(receive(:expiry_warning)) # rubocop:disable RSpec/MessageSpies
      expect { service_call }
        .not_to(change { account.reload.expiry_warning_sent_on })
    end
  end

  context 'when account expires less than 30 days from now' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:expires_on) { 29.days.from_now }
    let(:expiry_warning_sent_on) { nil }

    it 'does not send an email' do # rubocop:disable RSpec/MultipleExpectations
      expect(AccountMailer).to(receive(:expiry_warning)).and_return(mailer) # rubocop:disable RSpec/MessageSpies
      expect(mailer).to(receive(:deliver)) # rubocop:disable RSpec/MessageSpies

      expect { service_call }
        .to(change { account.reload.expiry_warning_sent_on }
        .to(Date.current))
    end
  end

  context 'when account expires less than 30 days from now, and users have been notified' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:expires_on) { 29.days.from_now }
    let(:expiry_warning_sent_on) { 30.days.from_now }

    it 'does not send an email' do # rubocop:disable RSpec/MultipleExpectations
      expect(AccountMailer).not_to(receive(:expiry_warning)) # rubocop:disable RSpec/MessageSpies
      expect { service_call }
        .not_to(change { account.reload.expiry_warning_sent_on })
    end
  end

  context 'when account has already expired' do # rubocop:disable RSpec/MultipleMemoizedHelpers
    let(:expires_on) { 1.day.ago }
    let(:expiry_warning_sent_on) { nil }

    it 'does not send an email' do # rubocop:disable RSpec/MultipleExpectations
      expect(AccountMailer).not_to(receive(:expiry_warning)) # rubocop:disable RSpec/MessageSpies
      expect { service_call }
        .not_to(change { account.reload.expiry_warning_sent_on })
    end
  end
end
