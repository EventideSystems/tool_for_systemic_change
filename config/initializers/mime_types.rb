# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf


unless defined? Mime::XLSX
	Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx
end

unless Mime::Type.lookup_by_extension(:pdf)
  Mime::Type.register_alias("application/pdf", :pdf)
end