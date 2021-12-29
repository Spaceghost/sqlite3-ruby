# support multiple ruby version (fat binaries under windows)
begin
  RUBY_VERSION =~ /(\d+\.\d+)/
  require "sqlite3/#{$1}/sqlite3_native"
rescue LoadError
  require 'sqlite3/sqlite3_native'
end

require 'sqlite3/database'
require 'sqlite3/version'
require 'sqlite3/vfs'
require 'sqlite3/vfs/file'

module SQLite3
  # Was sqlite3 compiled with thread safety on?
  def self.threadsafe?; threadsafe > 0; end
end
