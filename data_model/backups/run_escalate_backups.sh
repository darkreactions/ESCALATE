#!/bin/bash

# g.cattabriga
#
# generate postgresql backups for escalate v3
# both create and refresh sql files
# post-process the sql files to make sure extensions are added and 'drop schema' is commented out
# see AWK scripts for details of post-processing

# 1) produce a backup that will restore the database from scratch (i.e. drop the schema)
echo "running escalate_dev_create_backup sql (pg_dump)"
pg_dump -h localhost -O  -n 'dev' -U escalate -d escalate -Fp  -T 'dev.load_all*' -T 'dev.load_emo*'  -T 'dev.load_tie*' -T 'dev.load_vers*'  > escalate_dev_create_backup.sql

# need to change the some lines in the 'create' sql
echo "post processing escalate_dev_create_backup.sql (postprocess_create_sql.awk)"
./postprocess_create_sql.awk escalate_dev_create_backup.sql > escalate_dev_create_backup.tmp && mv escalate_dev_create_backup.tmp escalate_dev_create_backup.sql


# 2) produce backup that will restore the database only refreshing the core escalate v3 objects
echo "running escalate_dev_refresh_backup sql (pg_dump)"
pg_dump -h localhost -O  -n 'dev' -U escalate -d escalate -Fp  -c -T 'dev.load_all*' -T 'dev.load_emo*'  -T 'dev.load_tie*' -T 'dev.load_vers*'  > escalate_dev_refresh_backup.sql
# need to change the some lines in the 'refresh' sql
echo "post processing escalate_dev_refresh_backup.sql (postprocess_refresh_sql.awk)"
./postprocess_refresh_sql.awk escalate_dev_refresh_backup.sql > escalate_dev_refresh_backup.tmp && mv escalate_dev_refresh_backup.tmp escalate_dev_refresh_backup.sql

echo "done"


