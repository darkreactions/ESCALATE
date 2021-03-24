#!/bin/bash

# g.cattabriga
#
# rebuild the escalate v3 schema, functions, views from scratch
# run some tests from test_functions.sql

PGOPTIONS="--search_path=dev"
export PGOPTIONS

rm rebuild_dev.log 
(cd ../sql_test && rm test_dev.log)

echo "creating tables..."
psql -h `ipaddr` -d escalate -U escalate -f prod_tables.sql  > rebuild_dev.log 2>&1

echo "creating functions..."
psql -h `ipaddr` -d escalate -U escalate -f prod_functions.sql >> rebuild_dev.log 2>&1

echo "creating upserts..."
psql -h `ipaddr` -d escalate -U escalate -f prod_upserts.sql >> rebuild_dev.log 2>&1

echo "creating views..."
psql -h `ipaddr` -d escalate -U escalate -f prod_views.sql >> rebuild_dev.log 2>&1

echo "initializing core tables..."
psql -h `ipaddr` -d escalate -U escalate -f prod_initialize_coretables.sql >> rebuild_dev.log 2>&1

echo "updating materials..."
psql -h `ipaddr` -d escalate -U escalate -f hc_load_1_material.sql >> rebuild_dev.log 2>&1

echo "updating inventory..."
psql -h `ipaddr` -d escalate -U escalate -f hc_load_2_inventory.sql >> rebuild_dev.log 2>&1

echo "updating calculations..."
psql -h `ipaddr` -d escalate -U escalate -f hc_load_3_calculation.sql >> rebuild_dev.log 2>&1

echo "running ETL..."
psql -h `ipaddr` -d escalate -U escalate -f prod_etl.sql >> rebuild_dev.log 2>&1

## run SQL function tests
echo "running tests..."
(cd ../sql_test && psql -h `ipaddr` -d escalate -U escalate -f test_functions.sql >> test_dev.log 2>&1)


echo "Loading Separation materials"
psql -h `ipaddr` -d escalate -U escalate -f dev_sep_materials.sql >> rebuild_dev.log 2>&1

echo "Loading Separation actions"
psql -h `ipaddr` -d escalate -U escalate -f dev_sep_actions.sql >> rebuild_dev.log 2>&1

echo "Loading Separation liq sol"
psql -h `ipaddr` -d escalate -U escalate -f dev_sep_wf_liq_sol.sql >> rebuild_dev.log 2>&1

echo "Loading Separation resin weigh"
psql -h `ipaddr` -d escalate -U escalate -f dev_sep_resin_weigh.sql >> rebuild_dev.log 2>&1

echo "done (test_dev.log)"
(cd ../sql_test && awk 'BEGIN { count=0 } /ERROR:/ {print $0;count++ } END { print "error count: ", count }' test_dev.log)
