# frozen_string_literal: true

HEROKU_STAGING_DEPLOY = <<~BASH
  git push -f tool-for-systemic-change-stg staging:master && \
  heroku run rake db:migrate -a tool-for-systemic-change-stg && \
  heroku run rake data:migrate -a tool-for-systemic-change-stg && \
  heroku restart -a tool-for-systemic-change-stg
BASH

HEROKU_PRODUCTION_DEPLOY = <<~BASH
  git push -f tool-for-systemic-change-prod master:master && \
  heroku run rake db:migrate -a tool-for-systemic-change-prod && \
  heroku run rake data:migrate -a tool-for-systemic-change-prod && \
  heroku restart -a tool-for-systemic-change-prod
BASH

namespace :deploy do # rubocop:disable Metrics/BlockLength
  def print_warning(deploy_environment)
    printf <<~TEXT
      \033[31m
      WARNING! You are about to deploy to the tool-for-systemic-change '#{deploy_environment}' environment.
      \033[0m
    TEXT
  end

  def print_confirmation(deploy_environment)
    print "Are you ready to release to '#{deploy_environment}'? Type 'yes' to continue: "
  end

  def confirmed?
    $stdin.gets.strip.upcase == 'YES'
  end

  desc 'deploy to staging environment'
  task staging: :environment do
    print_warning('staging')
    print_confirmation('staging')
    if confirmed?
      sh(HEROKU_STAGING_DEPLOY)
    else
      puts 'Cancelling release.'
    end
  end

  desc 'deploy to production environment'
  task production: :environment do
    print_warning('PRODUCTION')
    print_confirmation('PRODUCTION')
    if confirmed?
      sh(HEROKU_PRODUCTION_DEPLOY)
    else
      puts 'Cancelling release.'
    end
  end
end
