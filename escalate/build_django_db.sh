#!/bin/bash
export DJANGO_SETTINGS_MODULE=escalate.settings.local
if [[ "$1" = "flush" ]]; then
    python manage.py flush
elif [[ "$1" = "reset" ]]; then
    python manage.py reset_schema
fi

rm -r ./core/migrations/00*.py
python manage.py makemigrations
python manage.py migrate
python manage.py load_standard
python manage.py load_organization
python manage.py load_person
python manage.py load_systemtool
python manage.py load_inventory
python manage.py load_loadtables
python manage.py setup_users
