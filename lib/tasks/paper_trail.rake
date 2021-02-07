# frozen_string_literal: true

namespace :paper_trail do

  desc 'Convert versions to use JSONB'
  task convert_versions: :environment do
    version_count = PaperTrail::Version.where.not(old_object: nil).count

    puts "#{version_count} records left to convert. Converting..."

    PaperTrail::Version.where.not(old_object: nil).find_each do |version|
      version.update_columns old_object: nil, object: YAML.load(version.old_object)
    end

    puts "\n\nDone."
  end
end
