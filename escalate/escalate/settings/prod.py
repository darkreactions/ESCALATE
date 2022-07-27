import os

from escalate.escalate.settings.dev import SECRET_KEY
from .base import *
from django.core.management.utils import get_random_secret_key

DEBUG = 0
# SECRET_KEY = "1qhmd^+6(k3t4$*^ws5px-f+loyi_%6@p)h33qha2z9wy6=*!4"
SECRET_KEY = get_random_secret_key()
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "0.0.0.0", "escalate.sd2e.org", "[::1]"]

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "escalate",
        "USER": "escalate",
        "PASSWORD": "SD21sAwes0me3",
        "HOST": "escalate-postgres",
        "PORT": 5432,
        "OPTIONS": {
            #'options': '-c search_path=prod'
        },
    }
}
