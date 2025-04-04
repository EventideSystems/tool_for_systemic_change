# frozen_string_literal: true

namespace :users do
  namespace :system_admin do
    desc 'Create a new system admin user'
    task create: :environment do
      if ENV['EMAIL'].nil? || ENV['PASSWORD'].nil?
        puts 'EMAIL and PASSWORD are required'
        puts 'Usage: rake users:system_admin:create EMAIL="user@example.com PASSWORD="password"'
        exit(1)
      end

      puts 'Creating a new system admin user...'

      User.create!(
        email: ENV['EMAIL'],
        password: ENV['PASSWORD'],
        password_confirmation: ENV['PASSWORD'],
        system_role: :admin
      )

      puts 'System admin user created successfully.'
    end
  end
end
