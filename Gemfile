source 'https://rubygems.org'

ruby '2.7.5' unless ENV['CI']

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '>= 6.1.4.2'
# Use postgresql as the database for Active Record
gem 'pg'
# Use Puma as the app server
gem 'puma', '>= 5.3.1'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
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
gem 'jbuilder', '~> 2.10'
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
gem 'mandrill_mailer'
gem 'pundit'

# User interface related
gem 'simple_form'
gem 'cocoon'
gem 'carrierwave', '~> 1.0'
gem 'mini_magick'
gem 'table-for'
gem 'kaminari'
gem 'breadcrumbs_on_rails', '<= 3.0.1'
gem 'nokogiri_truncate_html'
gem 'bootstrap_form', '<= 2.1.1'
gem 'trix-rails', require: 'trix'
gem 'nested_form_fields'

# Report related
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'caxlsx'
gem 'roo', '~> 2.7.0'
gem 'prawn'
gem 'prawn-table'
gem 'rubyzip', '>= 1.3.0'
gem 'scenic'

gem 'marcel'
gem 'shrine', '>= 3.3.0'
gem 'rollbar'
gem 'scout_apm'

gem 'paranoia', '~> 2.2'
gem 'paper_trail'
gem 'delayed_job_active_record'
gem 'daemons'
# gem 'mailjet'
gem 'data_migrate'
gem 'aws-sdk-lambda'
gem 'aws-sdk-rails'

gem 'hashie', '~> 3.4', '< 3.5' # NOTE Older version to avoid spamming the log
gem 'thor'

# Profiling related
gem 'rack-mini-profiler'
gem 'memory_profiler'
gem 'stackprof'

group :test do
  gem 'cucumber-rails', :require => false
  # database_cleaner is not required, but highly recommended
  gem 'database_cleaner'
  gem 'rails-controller-testing'
  gem 'timecop'
  gem 'rspec_junit_formatter'
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'pry'
  gem 'pry-byebug'
  # NOTE Currently errors out
  # gem 'pry-coolline'
  gem 'pry-stack_explorer'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
  gem 'rspec-rails'
  gem 'factory_bot_rails', require: false
  gem 'ffaker'
  gem 'bullet'
  gem 'rubycritic'
  gem 'dotenv-rails'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'brakeman', require: false
  gem 'bundler-audit'
  gem 'ruby-prof'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
