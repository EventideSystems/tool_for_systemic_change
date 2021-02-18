# frozen_string_literal: true

namespace :deploy do

  HEROKU_STAGING_DEPLOY = <<~BASH
    git push wickedlab-staging staging:master && \
    heroku run rake db:migrate -a wickedlab-staging && \
    heroku run rake data:migrate -a wickedlab-staging && \
    heroku restart -a wickedlab-staging
  BASH

  HEROKU_PRODUCTION_DEPLOY = <<~BASH
    git push wickedlab-production master:master && \
    heroku run rake db:migrate -a wickedlab && \
    heroku run rake data:migrate -a wickedlab-staging && \
    heroku restart -a wickedlab
  BASH

  def print_warning(deploy_environment)
    printf <<~TEXT
      \033[31m
      WARNING! You are about to deploy to the wickedlab '#{deploy_environment}' environment.
      \033[0m
    TEXT
  end

  def print_confirmation(deploy_environment)
    print "Are you ready to release to '#{deploy_environment}'? Type 'yes' to continue: "
  end

  def confirmed?
    STDIN.gets.strip.upcase == 'YES'
  end

  desc "deploy to staging environment"
  task :staging do
    print_warning('staging')
    print_confirmation('staging')
    if confirmed?
      sh(HEROKU_STAGING_DEPLOY)
    else
      puts 'Cancelling release.'
    end
  end

  desc "deploy to production environment"
  task :production do
    print_warning('PRODUCTION')
    print_confirmation('PRODUCTION')
    if confirmed?
      sh(HEROKU_PRODUCTION_DEPLOY)
    else
      puts 'Cancelling release.'
    end
  end
end
