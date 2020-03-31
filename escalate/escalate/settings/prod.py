import os
from .base import *

DEBUG = 0
SECRET_KEY = '1qhmd^+6(k3t4$*^ws5px-f+loyi_%6@p)h33qha2z9wy6=*!4'
ALLOWED_HOSTS = ["localhost", "127.0.0.1",
                 "0.0.0.0", "escalate.sd2e.org", "[::1]"]

DATABASES = {
    'default': {
        "ENGINE": 'django.db.backends.postgresql',
        "NAME": 'escalate',
        "USER": 'escalate',
        "PASSWORD": 'SD21sAwes0me3',
        "HOST": 'escalate-postgres',
        "PORT": 5432,
        'OPTIONS': {
            'options': '-c search_path=prod'
        }
    }
}
