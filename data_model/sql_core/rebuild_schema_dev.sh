#!/bin/bash

# g.cattabriga
#
# rebuild the escalate v3 schema, functions, views from scratch

PGOPTIONS="--search_path=dev"
export PGOPTIONS

rm rebuild_dev.log 

# 1) produce a backup that will restore the database from scratch (i.e. drop the schema)
echo "create the tables..."
psql -d escalate -U escalate -f prod_create_tables.sql  > rebuild_dev.log 2>&1

echo "create the functions..."
psql -d escalate -U escalate -f prod_create_functions.sql >> rebuild_dev.log 2>&1

echo "create the views..."
psql -d escalate -U escalate -f prod_create_views.sql >> rebuild_dev.log 2>&1

echo "initialize core tables..."
psql -d escalate -U escalate -f prod_initialize_coretables.sql >> rebuild_dev.log 2>&1

echo "update materials..."
psql -d escalate -U escalate -f prod_update_1_material.sql >> rebuild_dev.log 2>&1

echo "update inventory..."
psql -d escalate -U escalate -f prod_update_2_inventory.sql >> rebuild_dev.log 2>&1

echo "update descriptors..."
psql -d escalate -U escalate -f prod_update_3_descriptor.sql >> rebuild_dev.log 2>&1

echo "done"


