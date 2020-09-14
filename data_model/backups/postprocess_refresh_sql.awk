#!/usr/bin/awk -f

# super simple awk program to look for pattern in sql file and either add or modify
# feed in the input sql file and specify the output file with >
# example ./postprocess_refresh_sql.awk escalate_dev_refresh_backup.sql > escalate_dev_refresh_backup.tmp && mv escalate_dev_refresh_backup.tmp escalate_dev_refresh_backup.sql
BEGIN {
	cmd="date -u +%Y-%m-%dT%H:%M:%SZ";
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
	else if (index ($0, "-- PostgreSQL database dump"))
		{
			print "-- |==================================================|"					
			print "-- | Filename:       escalate_dev_refresh_backup.sql  |"
			print "-- | Timestamp:     ",ts, "            |"
			print "-- | Post-process:   postprocess_refresh_sql.awk      |"				
			print "-- |==================================================|"
			print "--"
			print $0
			next
		}
	# add insurance that old material_refname_type gets dropped
	else if (index ($0, "DROP TABLE dev.material_refname_def"))
		{
			gsub(";"," CASCADE;")
			print $0
			print "-- added next line in post-processing to ensure old [material_refname_type] table is dropped"
			print "DROP TABLE dev.material_refname_type CASCADE;"
			next
		}	# add cascade option to all tables to make sure we elliminate all dependent objects
	else if (index ($0, "DROP TABLE"))
		{
			gsub(";"," CASCADE;")
			print $0
			next
		}
	else if (index ($0, "DROP TRIGGER"))
		{
			gsub(";"," CASCADE;")
			print $0
			next
		}
	else if (index ($0, "DROP INDEX"))
		{
			gsub(";"," CASCADE;")
			print $0
			next
		}
	else if (index ($0, "DROP VIEW"))
		{
			gsub(";"," CASCADE;")
			print $0
			next
		}
	else if (index ($0, "DROP SEQUENCE"))
		{
			gsub(";"," CASCADE;")
			print $0
			next
		}
	else if (index ($0, "DROP FUNCTION"))
		{
			gsub(";"," CASCADE;")
			print $0
			next
		}
	else if (index ($0, "DROP TYPE"))
		{
			gsub(";"," CASCADE;")
			print $0
			next
		}
	else 
		print $0
}
END {}
