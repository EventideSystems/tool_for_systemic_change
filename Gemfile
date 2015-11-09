source "https://rubygems.org"


# Bundle edge Rails instead: gem "rails", github: "rails/rails"
gem "rails", "4.2.3"
# Use Postgres as the database for Active Record
gem "pg"
# Use SCSS for stylesheets
gem "sass-rails", "~> 5.0"
# Use Uglifier as compressor for JavaScript assets
gem "uglifier", ">= 1.3.0"
# Use CoffeeScript for .coffee assets and views
gem "coffee-rails", "~> 4.1.0"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem "therubyracer", platforms: :ruby

# Use jquery as the JavaScript library
gem "jquery-rails"

# SMELL Using non-official fork of active_model_serializers, until support for
# lower camel case is incorporated in the current main repo
# gem "active_model_serializers",
#   git: "git://github.com/jfelchner/active_model_serializers.git",
#   branch: "feature/default-json-api-to-dasherized-keys"

gem "active_model_serializers",
  git: "git://github.com/rails-api/active_model_serializers.git",
  :branch => "0-10-stable"

# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc", "~> 0.4.0", group: :doc

# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Use Unicorn as the app server
gem "unicorn"

# Use Capistrano for deployment
# gem "capistrano-rails", group: :development

# Authentication & authorization
gem "devise"
gem "devise_invitable"
gem "pundit"
gem "rails_admin_pundit", :github => "sudosu/rails_admin_pundit"

# Asset management
gem "bower-rails"
gem "apipie-rails", :github => "Apipie/apipie-rails"

# System administration
gem "rails_admin"

# Pagination
gem 'kaminari'

# Activity logging
gem 'public_activity'

gem 'redcarpet'

gem "bullet", group: "test"

group :development do
  # Documentation support
  gem "railroady"
  gem "rubocop"
end

group :development, :test do
  # Testing
  gem "rspec-rails", "~> 3.0"
  gem "factory_girl_rails"
  gem "ffaker"
  gem "database_cleaner"
  # Debugging
  gem "byebug"
  gem "pry"
  gem "pry-byebug"
  gem "pry-coolline"
  gem "pry-stack_explorer"

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 2.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"
end

