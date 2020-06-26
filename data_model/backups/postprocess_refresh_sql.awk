#!/usr/bin/awk -f

# super simple awk program to look for pattern in sql file and either add or modify
# feed in the input sql file and specify the output file with >
# example ./postprocess_refresh_sql.awk escalate_dev_refresh_backup.sql > escalate_dev_refresh_backup.tmp && mv escalate_dev_refresh_backup.tmp escalate_dev_refresh_backup.sql
BEGIN {
	cmd="date +%m/%d/%Y_%H:%M:%S_%a";
	cmd|getline ts; 
	close(cmd);
}
{
	# add in the dev schema to the search_path
	if (index ($0, "'search_path', '', false"))
		{ 
			gsub("search_path\047\, \047\047","search_path\047\, \047dev\047")
			print $0
			next
		}
		# comment out the drop schema
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
	# add the filename and timestamp
	else if (index ($0, "-- Dumped by pg_dump"))
		{
			print $0
			print ""
			print "-- ****************************************************"
			print "-- *         escalate_dev_refresh_backup.sql          *"
			print "-- *            ", ts, "             *"
			print "-- ****************************************************"
			next
		}
	# add cascade option to all tables to make sure we elliminate all dependent objects
	else if (index ($0, "DROP TABLE"))
		{
			gsub(";"," CASCADE;")
			print $0
			next
		}	
	else 
		print $0
}
END {}
