source 'https://rubygems.org'

ruby '2.3.4' unless ENV['CI']

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.6'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Authentication and authorisation
gem 'devise'
gem 'devise_invitable'
gem 'pundit'

# User interface 
gem 'bootstrap-sass'
gem 'font-awesome-sass'
gem 'simple_form'
gem 'carrierwave', '~> 1.0'
gem 'mini_magick'
gem 'nested_form_fields'
gem 'table-for'
gem 'kaminari-bootstrap'
gem 'breadcrumbs_on_rails'
gem 'nokogiri_truncate_html'
gem 'bootstrap-datepicker-rails'
gem 'bootstrap_form'

# Report related
gem 'wkhtmltopdf-binary'
gem 'wicked_pdf'
gem 'axlsx', '2.1.0.pre'
gem 'roo', '~> 2.7.0'
gem 'prawn'
gem 'prawn-table'

gem 'shrine'
gem 'rollbar'
gem 'scout_apm'

# SMELL See https://github.com/tenex/rails-assets/issues/417
#source 'http://insecure.rails-assets.org/' do
source 'https://rails-assets.org/' do
  gem 'rails-assets-adminlte'  
  gem 'rails-assets-medium-editor'
  gem 'rails-assets-twitter-bootstrap-wizard'
  gem 'rails-assets-select2'
  gem 'rails-assets-bootstrap-nav-wizard'
  gem 'rails-assets-bootstrap-daterangepicker'
  gem 'rails-assets-moment'
  # gem 'rails-assets-clipboard'
end

gem 'paranoia', '~> 2.2'
gem 'paper_trail'
gem 'delayed_job_active_record'
gem 'daemons'
gem 'mailjet'

gem 'hashie', '~> 3.4', '< 3.5' # NOTE Older version to avoid spamming the log

gem 'thor', '~> 0.20'

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
  gem 'pry-coolline'
  gem 'pry-stack_explorer'
  gem 'rubocop', require: false
  gem 'rspec-rails', '~> 3.5'
  gem 'factory_girl_rails', :require => false
  gem 'ffaker'
  gem 'bullet'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'brakeman', require: false
  gem 'bundler-audit'
  gem 'ruby-prof'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
