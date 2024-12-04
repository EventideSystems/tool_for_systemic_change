Rack::Attack.blocklist("block all access to admin") do |request|
  # Block WP probes
  request.path.include?('/wp-includes')
end
