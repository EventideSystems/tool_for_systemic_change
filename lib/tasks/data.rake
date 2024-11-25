# frozen_string_literal: true

namespace :data do
  namespace :migrate do
    desc 'Reset data migrations in current branch down to master'
    task :down_to_master do
      `git diff master | grep  '+++ b/db/data/\d*'`
        .split("\n")
        .map { |line| line.split('/').last.split('_').first }
        .tap { |migrations| puts "Resetting #{migrations.size} data migration(s)" }
        .reverse
        .map { |id| "bundle exec rails data:migrate:down VERSION=#{id}" }
        .each { |command| sh(command) }
    end
  end
end
