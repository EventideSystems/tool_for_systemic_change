Rack::Attack.blocklist("block all access to wp") do |request|
  # Block WP probes
  request.path.include?('/wp-includes')
end
