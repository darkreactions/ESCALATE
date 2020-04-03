from core.models import (Actor, Material, Inventory,
                         Person, Organization, Note)
from rest_framework.serializers import HyperlinkedModelSerializer, CharField
import core.models
from .utils import model_names, view_names


model_names = model_names + view_names

for model_name in model_names:
    meta_class = type('Meta', (), {'model': getattr(core.models, model_name),
                                   'fields': '__all__'})
    globals()[model_name+'Serializer'] = type(model_name+'Serializer', tuple([HyperlinkedModelSerializer]),
                                              {'Meta': meta_class})
