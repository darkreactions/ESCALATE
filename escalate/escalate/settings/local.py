import os
from .base import *

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEBUG = 1
SECRET_KEY = "1qhmd^+6(k3t4$*^ws5px-f+loyi_%6@p)h33qha2z9wy6=*!4"
ALLOWED_HOSTS = ["localhost", "127.0.0.1", "0.0.0.0", "escalate.sd2e.org", "[::1]"]
DATA_UPLOAD_MAX_NUMBER_FIELDS = 10000

SQLITE = False

if SQLITE:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.sqlite3",
            "NAME": os.path.join(BASE_DIR, "db.sqlite3"),
        }
    }
else:
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": "escalate",
            "USER": "escalate",
            "PASSWORD": "SD21sAwes0me3",
            "HOST": "localhost",
            "PORT": 5432,
            "OPTIONS": {
                #'options': '-c search_path=dev'
            },
        }
    }
