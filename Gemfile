# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.4.2'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem 'tailwindcss-rails', '~> 4.2.2'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
gem 'redis', '>= 4.0.1'

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem 'image_processing', '~> 1.2'
gem 'shadcn-ui', '~> 0.0.13'
gem 'view_component'

gem 'fast_jsonparser'

# Authentication and authorisation
gem 'devise'
gem 'devise_invitable'
gem 'mailjet'
gem 'pretender'
gem 'pundit'

# Report related
gem 'caxlsx'
gem 'csv'
# gem 'roo'
gem 'rubyzip', '>= 1.3.0'
gem 'scenic'

# gem 'marcel'
# gem 'shrine', '>= 3.3.0'

gem 'aws-sdk-lambda'
gem 'aws-sdk-rails'

gem 'data_migrate'

gem 'net-http'
gem 'pagy'
gem 'paper_trail'
gem 'paranoia'
gem 'ransack'
gem 'recaptcha'

# Monitoring related
gem 'appsignal'
gem 'rack-attack'

group :development, :test do
  gem 'dotenv'
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]

  gem 'factory_bot_rails', require: false
  gem 'ffaker'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-capybara'
  gem 'rubocop-factory_bot', require: false
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubocop-rspec_rails'
end

group :development do
  gem 'annotaterb'
  gem 'brakeman', require: false
  gem 'bundler-audit'
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'selenium-webdriver'
  gem 'timecop'
end
