#!/bin/bash

# g.cattabriga
#
# rebuild the escalate v3 schema, functions, views from scratch

PGOPTIONS="--search_path=dev"
export PGOPTIONS

rm rebuild_dev.log 

# 1) produce a backup that will restore the database from scratch (i.e. drop the schema)
echo "creating tables..."
psql -d escalate -U escalate -f prod_tables.sql  > rebuild_dev.log 2>&1

echo "creating functions..."
psql -d escalate -U escalate -f prod_functions.sql >> rebuild_dev.log 2>&1

echo "creating upserts..."
psql -d escalate -U escalate -f prod_upserts.sql >> rebuild_dev.log 2>&1

echo "creating views..."
psql -d escalate -U escalate -f prod_views.sql >> rebuild_dev.log 2>&1

echo "initializing core tables..."
psql -d escalate -U escalate -f prod_initialize_coretables.sql >> rebuild_dev.log 2>&1

echo "updating materials..."
psql -d escalate -U escalate -f prod_update_1_material.sql >> rebuild_dev.log 2>&1

echo "updating inventory..."
psql -d escalate -U escalate -f prod_update_2_inventory.sql >> rebuild_dev.log 2>&1

echo "updating calculations..."
psql -d escalate -U escalate -f prod_update_3_calculation.sql >> rebuild_dev.log 2>&1

echo "running ETL..."
psql -d escalate -U escalate -f prod_etl.sql >> rebuild_dev.log 2>&1

echo "done (rebuild_dev.log)"

awk 'BEGIN { count=0 } /ERROR:/ {print $0;count++ } END { print "error count: ", count }' rebuild_dev.log
