#!/bin/sh

export DEBUG=1
export SECRET_KEY="1qhmd^+6(k3t4$*^ws5px-f+loyi_%6@p)h33qha2z9wy6=*!4"
export DJANGO_ALLOWED_HOSTS="localhost 127.0.0.1 [::1] 0.0.0.0 escalate.sd2e.org"
export SQL_ENGINE=django.db.backends.postgresql
export SQL_DATABASE=escalate
export SQL_USER=escalate
export SQL_PASSWORD=SD21sAwes0me3
export SQL_HOST=escalate-postgres
export SQL_PORT=5432
export DATABASE=postgres

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $SQL_HOST $SQL_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi



python manage.py flush --no-input
python manage.py migrate

exec "$@"
#python manage.py runserver

