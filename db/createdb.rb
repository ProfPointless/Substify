require_relative "sqlite_connector"

drop_database("development") {}

use_database "development" do |db|
	db.execute "CREATE TABLE songs(id INTEGER PRIMARY KEY, titel TEXT NOT NULL, songtext TEXT NOT NULL, laenge INTEGER, erschienen_in INTEGER);"
end