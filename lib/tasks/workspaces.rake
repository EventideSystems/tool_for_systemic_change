# frozen_string_literal: true

namespace :workspaces do
  desc 'Update workspace expiry warnings'
  task update_expiry_warnings: :environment do
    WorkspaceExpiryWarningNotifier.call
  end

  desc 'List workspaces'
  task list: :environment do
    Workspace.all.find_each do |workspace|
      puts "#{workspace.id}: #{workspace.name}"
    end
  end

  desc 'Copy workspace'
  task copy: :environment do
    if ENV['WORKSPACE_NAME'].nil?
      puts 'WORKSPACE_NAME is required'
      exit(1)
    end

    workspace = Workspace.find_by(name: ENV.fetch('WORKSPACE_NAME', nil))

    if workspace.nil?
      puts "Workspace not found: #{ENV.fetch('WORKSPACE_NAME', nil)}"
      exit(1)
    end

    Workspaces::Copy.call(workspace:, new_name: ENV.fetch('NEW_WORKSPACE_NAME', nil)).tap do |new_workspace|
      puts "New workspace created: #{new_workspace.name}"
    end
  end
end
