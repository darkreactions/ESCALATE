from django.db import models

class Document(models.Model):
    description = models.CharField(max_length=255)
    document = models.BinaryField()
    doctype = models.CharField(max_length=255)
    version = models.CharField(max_length=255)
    alias = models.CharField(max_length=255)
    add_dt = models.DateTimeField()
    mod_dt = models.DateTimeField()

class Note(models.Model):
    notetext = models.CharField(max_length=255)
    document = Document()
    add_dt = models.DateTimeField()
    mod_dt = models.DateTimeField()

class CommonFields(models.Model):
    note = models.ForeignKey(Note, on_delete=models.CASCADE)
    alias = models.CharField(max_length=255)
    add_dt = models.DateTimeField()
    mod_dt = models.DateTimeField()
    description = models.CharField(max_length=255)

    class Meta:
        abstract = True

class Tag(CommonFields):
    pass


from .organization import *
from .actions import *
from .descriptors import *
from .ingredients import *
from .measures import *
from .science import *
from .tracking import *