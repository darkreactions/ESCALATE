from django.contrib import admin
from .models import (Organization, Material, Status)
from .models import CustomUser

# Register your models here.
admin.site.register(Organization)
admin.site.register(Material)
admin.site.register(Status)
admin.site.register(CustomUser)
