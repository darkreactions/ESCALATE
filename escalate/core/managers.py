from django.contrib.auth.base_user import BaseUserManager
from django.utils.translation import ugettext_lazy as _
from django.db import models

class CustomUserManager(BaseUserManager):
    """
    Custom user model manager where email is the unique identifiers
    for authentication instead of usernames.
    """
    def create_user(self, username, password, **extra_fields):
        """
        Create and save a User with the given email and password.
        """
        
        user = self.model(username=username, **extra_fields)
        user.set_password(password)
        user.save()
        return user

    def create_superuser(self, username, password, **extra_fields):
        """
        Create and save a SuperUser with the given email and password.
        """
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('is_active', True)

        if extra_fields.get('is_staff') is not True:
            raise ValueError(_('Superuser must have is_staff=True.'))
        if extra_fields.get('is_superuser') is not True:
            raise ValueError(_('Superuser must have is_superuser=True.'))
        return self.create_user(username, password, **extra_fields)


class ExperimentTemplateManager(models.Manager):
    def get_queryset(self):
        return super(ExperimentTemplateManager, self).get_queryset().filter(
            parent__isnull=True)

    def create(self, **kwargs):
        #kwargs.update({'type': 'video'})
        kwargs.update({'parent': None})
        return super(ExperimentTemplateManager, self).create(**kwargs)


class ExperimentInstanceManager(models.Manager):
    def get_queryset(self):
        return super(ExperimentInstanceManager, self).get_queryset().filter(
            parent__isnull=False)

    def create(self, **kwargs):
        return super(ExperimentInstanceManager, self).create(**kwargs)