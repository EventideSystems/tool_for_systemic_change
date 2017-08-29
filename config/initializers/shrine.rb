require "shrine"
require "shrine/storage/file_system"

Shrine.storages = {
  cache: Shrine::Storage::FileSystem.new("private", prefix: "uploads/cache"),
  store: Shrine::Storage::FileSystem.new("private", prefix: "uploads/store")
}

Shrine.plugin :activerecord
Shrine.plugin :remove_invalid
Shrine.plugin :cached_attachment_data