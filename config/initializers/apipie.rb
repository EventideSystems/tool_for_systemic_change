Apipie.configure do |config|
  config.app_name                = "WickedSoftware"
  config.api_base_url            = ""
  config.doc_base_url            = "/api_doc"
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
  config.validate_presence       = false
end
