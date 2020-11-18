#!/usr/bin/awk -f

# simple awk program to generate 'empty' table comments, rather than doing it manually 
# looks for pattern in sql file like:
# 'CREATE TABLE'
#  ending with: ');' 
# example command line: ./table_comment_gen.awk prod_tables.sql > comment_gen.sql
BEGIN {
	tablename = ""
	flag = 0;
}
{
	# need to make sure we start at a non comment
	if ($1 == "CREATE" && $2 == "TABLE" && !(flag))
	{
		tablename = $3
		print "COMMENT ON TABLE",$3,"IS '';"
		flag = 1
	}
	else if ($0 == ");" && (flag))
	{
		print "\n"
		flag = 0;
	}
	else if (flag)
	{
		print "COMMENT ON COLUMN",tablename"."$1,"IS '';"
	}
	else 
		next
}
END {}