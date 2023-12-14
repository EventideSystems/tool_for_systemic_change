source 'https://rubygems.org'

ruby '3.1.4' unless ENV['CI']

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 7.0.7.2'
# Use postgresql as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '~> 5.6.7'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '>= 4.3.4'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.10'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

gem 'bootsnap'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'webpacker'

# Authentication and authorisation
gem 'devise'
gem 'devise_invitable'
gem 'mailjet'
# gem 'mandrill_mailer'
gem 'pretender'
gem 'pundit'

# User interface related
gem 'bootstrap_form', '<= 2.1.1'
gem 'breadcrumbs_on_rails', '<= 3.0.1'
gem 'kaminari'
gem 'nested_form_fields'
gem 'nokogiri_truncate_html'
gem 'simple_form'
gem 'table-for'
gem 'trix-rails', require: 'trix'

# Report related
gem 'caxlsx'
gem 'prawn'
gem 'prawn-table'
gem 'roo'
gem 'rubyzip', '>= 1.3.0'
gem 'scenic'

gem 'marcel'
gem 'scout_apm'
gem 'shrine', '>= 3.3.0'

gem 'aws-sdk-lambda'
gem 'aws-sdk-rails'
gem 'data_migrate'
gem 'paper_trail'
gem 'paranoia', '~> 2.6'

gem 'net-http'

gem 'fast_jsonparser'

# Profiling related
gem 'memory_profiler'
gem 'rack-mini-profiler'
gem 'stackprof'

group :test do
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'rspec_junit_formatter'
  gem 'timecop'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'pry'
  gem 'pry-byebug'
  # NOTE: Currently errors out
  # gem 'pry-coolline'
  gem 'bullet'
  gem 'derailed_benchmarks'
  gem 'dotenv-rails'
  gem 'factory_bot_rails', require: false
  gem 'ffaker'
  gem 'pry-stack_explorer'
  gem 'rspec-rails'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rubycritic'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen'
  gem 'web-console'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'brakeman', require: false
  gem 'bundler-audit'
  gem 'ruby-prof'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem "matrix", "~> 0.4.2"
