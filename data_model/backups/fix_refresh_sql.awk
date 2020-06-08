#!/usr/bin/awk -f

# super simple awk program to look for pattern in sql file and either add or modify
# feed in the input sql file and speficy the output file with >
# example ./parse_sql.awk sql_backup.sql > output.sql
BEGIN {}
{
	# add in the dev schema to the search_path
	if (index ($0, "'search_path', '', false"))
		{ 
			gsub("search_path\047\, \047\047","search_path\047\, \047dev\047")
			print $0
			next
		}
		else if (index ($0, "DROP SCHEMA dev"))
		{
			print "-- DROP SCHEMA dev;"
			next
		}
	# add the create extension commands after the create schema
	else if (index ($0, "CREATE SCHEMA dev"))
		{
			print "-- CREATE SCHEMA dev;"
			print "CREATE EXTENSION if not exists ltree with schema dev;"
			print "CREATE EXTENSION if not exists tablefunc with schema dev;"
			print "CREATE EXTENSION if not exists \"uuid-ossp\" with schema dev;"
			print "CREATE EXTENSION IF NOT EXISTS hstore with schema dev;"
			print "SELECT set_config(\047search_path\047\, \047dev\,\047||current_setting(\047search_path\047), false);"
			next
		}
	else 
		print $0
}
END {}
