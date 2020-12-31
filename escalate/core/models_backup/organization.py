from django.db import models
from . import Note, Document, CommonFields

class Organization(CommonFields):
    name = models.CharField(max_length=255)
    address1 = models.CharField(max_length=255)
    address2 = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    state = models.CharField(max_length=255)
    zip = models.CharField(max_length=255)
    website_url = models.CharField(max_length=255)
    phone = models.CharField(max_length=255)

class Person(CommonFields):
    firstname = models.CharField(max_length=255)
    lastname = models.CharField(max_length=255)
    middlename = models.CharField(max_length=255)
    address1 = models.CharField(max_length=255)
    address2 = models.CharField(max_length=255)
    city = models.CharField(max_length=255)
    state = models.CharField(max_length=255)
    phone = models.CharField(max_length=255)
    email = models.CharField(max_length=255)
    title = models.CharField(max_length=255)
    suffix = models.CharField(max_length=255)
    organization = ForeignKey(Organization, on_delete=models.CASCADE)

class SystemType(CommonFields):
    pass

class System(CommonFields):
    name = models.CharField(max_length=255)
    systemtype = ForeignKey(SystemType, on_delete=models.CASCADE)
    vendor = models.CharField(max_length=255)
    model = models.CharField(max_length=255)
    serial = models.CharField(max_length=255)
    version = models.CharField(max_length=255)


