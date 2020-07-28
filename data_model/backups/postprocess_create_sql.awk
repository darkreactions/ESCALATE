#!/usr/bin/awk -f

# super simple awk program to update the escalate_dev_create_backup sql file
# example postprocess_create_sql.awk escalate_dev_create_backup.sql > escalate_dev_create_backup.tmp && mv escalate_dev_create_backup.tmp escalate_dev_create_backup.sql
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
	else if (index ($0, "-- PostgreSQL database dump"))
		{
			print "-- |==================================================|"				
			print "-- | Filename:       escalate_dev_create_backup.sql   |"
			print "-- | Timestamp:     ",ts, "            |"
			print "-- | Post-process:   postprocess_create_sql.awk       |"				
			print "-- |==================================================|"
			print "--"
			print $0
			next
		}
	else 
		print $0
}
END {}
