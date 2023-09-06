# frozen_string_literal: true

namespace :db do
  namespace :migrate do
    # rubocop:disable Rails/RakeEnvironment
    desc 'Reset migrations in current branch down to master'
    task :down_to_master do
      `git diff master | grep '+++ b/db/migrate/\d*'`
        .split("\n")
        .map { |line| line.split('/').last.split('_').first }
        .tap { |migrations| puts "Resetting #{migrations.size} migration(s)" }
        .reverse
        .map { |id| "bundle exec rails db:migrate:down VERSION=#{id}" }
        .each { |command| sh(command) }
    end
    # rubocop:enable Rails/RakeEnvironment
  end
end
