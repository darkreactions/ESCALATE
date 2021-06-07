export DJANGO_SETTINGS_MODULE=escalate.settings.local
python manage.py reset_db
# rm -r ./core/migrations/*
python manage.py makemigrations
python manage.py migrate
python manage.py setup_users