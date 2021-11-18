import pytest
from django.test import Client


@pytest.fixture(scope="session")
def django_db_setup():
    from django.conf import settings

    settings.DATABASES["default"] = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "escalate",
        "USER": "escalate",
        "PASSWORD": "SD21sAwes0me3",
        "HOST": "localhost",
        "PORT": 5432,
        "OPTIONS": {"options": "-c search_path=dev"},
    }
