from django.contrib import admin
from .models import (Organization, Material, Status, Tag, Actor, Person, Note)
from .models import CustomUser

# Register your models here.
admin.site.register(Organization)
admin.site.register(Material)
admin.site.register(Status)
admin.site.register(CustomUser)
admin.site.register(Tag)
admin.site.register(Actor)
admin.site.register(Person)
admin.site.register(Note)
