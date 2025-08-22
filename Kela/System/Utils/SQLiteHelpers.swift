import SQLite3

// Provide SQLITE_TRANSIENT for Swift bindings
let SQLITE_TRANSIENT = unsafeBitCast(-1, to: sqlite3_destructor_type.self)


