#!/bin/bash

# generate postgresql backups for escalate v3
# both the create and refresh sqlfiles

# 1) produce a backup that will restore the database from scratch (i.e. drop the schema)
pg_dump -O  -n 'dev' -U escalate -d escalate -Fp  -T 'dev.load_all*' -T 'dev.load_emo*'  -T 'dev.load_tie*' -T 'dev.load_vers*'  > escalate_dev_create_backup.sql

# need to change the some lines in the 'create' sql
./fix_create_sql.awk escalate_dev_create_backup.sql > escalate_dev_create_backup.tmp && mv escalate_dev_create_backup.tmp escalate_dev_create_backup.sql


# 2) produce backup that will restore the database only refreshing the core escalate v3 objects
pg_dump -O  -n 'dev' -U escalate -d escalate -Fp  -c -T 'dev.load_all*' -T 'dev.load_emo*'  -T 'dev.load_tie*' -T 'dev.load_vers*'  > escalate_dev_refresh_backup.sql
# need to change the some lines in the 'refresh' sql
./fix_refresh_sql.awk escalate_dev_refresh_backup.sql > escalate_dev_refresh_backup.tmp && mv escalate_dev_refresh_backup.tmp escalate_dev_refresh_backup.sql



