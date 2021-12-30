#if !defined(SQLITE3_VFS_RUBY) && defined(HAVE_SQLITE3_VFS_INIT)
#define SQLITE3_VFS_RUBY

#include <sqlite3_ruby.h>

void init_sqlite3_vfs();

#endif
