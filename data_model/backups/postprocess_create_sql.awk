#!/usr/bin/awk -f

# super simple awk program to update the escalate_dev_create_backup sql file
# example postprocess_create_sql.awk escalate_dev_create_backup.sql > escalate_dev_create_backup.tmp && mv escalate_dev_create_backup.tmp escalate_dev_create_backup.sql
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
	# add the create extension commands after the create schema
	else if (index ($0, "CREATE SCHEMA dev"))
		{
			print $0
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
			print "-- *          escalate_dev_create_backup.sql          *"
			print "-- *            ", ts, "             *"
			print "-- ****************************************************"
			next
		}
	else 
		print $0
}
END {}
