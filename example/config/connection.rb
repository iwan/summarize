require 'active_record'
require 'sqlite3'

module Connection
  ActiveRecord::Base.establish_connection(
    adapter:  'sqlite3',
    database: 'db/data.sqlite3'
  )
end

