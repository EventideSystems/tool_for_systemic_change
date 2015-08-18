# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Serialize json with camel case
Jbuilder.key_format camelize: :lower
