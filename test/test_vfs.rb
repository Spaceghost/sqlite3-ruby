require 'sqlite3'
require 'minitest/autorun'

if ENV['GITHUB_ACTIONS'] == 'true' || ENV['CI']
  $VERBOSE = nil
  puts "\nSQLite3 Version: #{SQLite3::SQLITE_VERSION}   $VERBOSE = nil", ""
else
  puts "\nSQLite3 Version: #{SQLite3::SQLITE_VERSION}", ""
end

unless RUBY_VERSION >= "1.9"
  require 'iconv'
end

module SQLite3
  class TestCase < Minitest::Test
    alias :assert_not_equal :refute_equal
    alias :assert_not_nil   :refute_nil
    alias :assert_raise     :assert_raises

    def assert_nothing_raised
      yield
    end
  end
end

# TEST
module SQLite3
  class TestVFS < TestCase
    class MyVFS < SQLite3::VFS
      def open name, flags
        SQLite3::VFS::StringIO.new name, flags
      end
    end

    SQLite3.vfs_register(MyVFS.new)

    def test_my_vfs
      db = SQLite3::Database.new('foo', nil, 'SQLite3::TestVFS::MyVFS')
    end

    def test_my_vfs_create_table
      db = SQLite3::Database.new('foo', nil, 'SQLite3::TestVFS::MyVFS')
      db.execute('create table ex(id int, data string)')
    end

    def test_read_write
      db = SQLite3::Database.new('foo', nil, 'SQLite3::TestVFS::MyVFS')
      db.execute('create table ex(id int, data string)')
      db.execute('insert into ex(id, data) VALUES (1, "foo")')
      assert_equal([[1, "foo"]], db.execute('select id, data from ex'))
    end

    def test_truncate
      db = SQLite3::Database.new('foo', nil, 'SQLite3::TestVFS::MyVFS')
      db.execute('PRAGMA auto_vacuum = 1')
      db.execute('create table ex(id int, data string)')
      db.execute('insert into ex(id, data) VALUES (1, "foo")')
      db.execute('drop table ex')
    end

    def test_check_reserved_lock
      fs = SQLite3::VFS::File.new 'foo', 1

      [
        VFS::LOCK_RESERVED,
        VFS::LOCK_PENDING,
        VFS::LOCK_EXCLUSIVE,
      ].each do |type|
        assert(!fs.reserved_lock?, 'not locked')
        fs.lock type
        assert(fs.reserved_lock?, 'locked')
        fs.unlock type
        assert(!fs.reserved_lock?, 'not locked')
      end

      [VFS::LOCK_SHARED, VFS::LOCK_NONE].each do |type|
        assert(!fs.reserved_lock?, 'not locked')
        fs.lock type
        assert(!fs.reserved_lock?, 'not locked')
        fs.unlock type
        assert(!fs.reserved_lock?, 'not locked')
      end
    end
  end
end
