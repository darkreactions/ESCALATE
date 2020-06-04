#!/bin/bash

# Run postgres normally
docker-entrypoint.sh "$@"
sleep 5
psql -p 5432 -h localhost -d escalate -U escalate -f escalate_dev_backup.sql
