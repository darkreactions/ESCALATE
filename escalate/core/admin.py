from django.contrib import admin
from .models import (Organization, Material, Status)

# Register your models here.
admin.site.register(Organization)
admin.site.register(Material)
admin.site.register(Status)
