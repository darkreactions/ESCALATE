from django.db import models
from django.contrib.auth.models import AbstractUser


from ..managers import CustomUserManager


class CustomUser(AbstractUser):

    REQUIRED_FIELDS = []

    objects = CustomUserManager()

    def __str__(self):
        return self.username
