#!/bin/bash
export DJANGO_SETTINGS_MODULE=escalate.settings.local
if [[ "$1" = "flush" ]]; then
    python manage.py flush
    python manage.py loaddata all_data
    python manage.py loaddata defaultvalues
    python manage.py loaddata reagentmaterialtemplate
elif [[ "$1" = "reset" ]]; then
    python manage.py reset_schema
    rm -r ./core/migrations/00*.py
    python manage.py makemigrations
    python manage.py migrate
    python manage.py loaddata all_data
    python manage.py loaddata defaultvalues
    python manage.py loaddata reagentmaterialtemplate
elif [[ "$1" = "backup" ]]; then
    python manage.py dumpdata --exclude=contenttypes > ./core/fixtures/all_data.json
    python manage.py dumpdata --indent 4 core.defaultvalues > ./core/fixtures/defaultvalues.json
    python manage.py dumpdata --indent 4 core.reagentmaterialtemplate > ./core/fixtures/reagentmaterialtemplate.json
fi

