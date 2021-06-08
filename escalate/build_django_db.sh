#!/bin/bash
export DJANGO_SETTINGS_MODULE=escalate.settings.local
if [[ "$1" = "flush" ]]; then
    python manage.py flush
elif [[ "$1" = "reset" ]]; then
    python manage.py reset_schema
fi

# python manage.py reset_db
# rm -r ./core/migrations/*
python manage.py makemigrations
python manage.py migrate
python manage.py setup_users