#!/usr/bin/awk -f

# super simple awk program to update the escalate_dev_create_backup sql file
# example postprocess_create_sql.awk escalate_dev_create_backup.sql > escalate_dev_create_backup.tmp && mv escalate_dev_create_backup.tmp escalate_dev_create_backup.sql
BEGIN {}
{
	# add in the dev schema to the search_path
	if (index ($0, "'null'"))
		{ 
			gsub("\047null\047", "NULL")
			print $0
			next
		}
	else 
		print $0
}
END {}
