from django.db import models
from . import Note, Document, CommonFields
from organization import Person, System

class Actor(CommonFields):
    person = models.ForeignKey(Person, on_delete=models.CASCADE)
    system = models.ForeignKey(System, on_delete=models.CASCADE)    

class Status(CommonFields):
    pass
