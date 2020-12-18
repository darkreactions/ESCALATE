from django.db import models
from django.contrib.auth.models import AbstractUser
#from .core_tables import Person

from ..managers import CustomUserManager


class CustomUser(AbstractUser):

    REQUIRED_FIELDS = []
    objects = CustomUserManager()
    person = models.ForeignKey(
        'PersonTable', on_delete=models.DO_NOTHING, null=True)

    def __str__(self):
        return self.username
