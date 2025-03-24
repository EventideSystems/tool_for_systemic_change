# frozen_string_literal: true

# Notify users when their workspace is about to expire.
class WorkspaceExpiryWarningNotifier
  class << self
    def call
      clear_warnings_for_renewed_workspaces
      send_notifications_for_expiring_workspaces
    end

    private

    EXPIRY_WARNING_PERIOD = Workspace::EXPIRY_WARNING_PERIOD

    def send_email(workspace, user)
      WorkspaceMailer.expiry_warning(workspace, user).deliver
    end

    def send_notifications_for_expiring_workspaces # rubocop:disable Metrics/MethodLength
      Workspace
        .where(expiry_warning_sent_on: nil)
        .where('expires_on <= ?', EXPIRY_WARNING_PERIOD.from_now)
        .where('expires_on > ?', EXPIRY_WARNING_PERIOD.ago)
        .where('expires_on > ?', Time.zone.today)
        .find_each do |workspace|
          workspace.users.find_each do |user|
            send_email(workspace, user)
          end
          workspace.update!(expiry_warning_sent_on: Date.current)
        end
    end

    def clear_warnings_for_renewed_workspaces
      Workspace
        .where.not(expiry_warning_sent_on: nil)
        .where.not(expires_on: nil)
        .where('expires_on > ?', EXPIRY_WARNING_PERIOD.from_now)
        .update_all(expiry_warning_sent_on: nil) # rubocop:disable Rails/SkipsModelValidations
    end
  end
end
