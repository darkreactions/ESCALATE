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
python manage.py setup_users