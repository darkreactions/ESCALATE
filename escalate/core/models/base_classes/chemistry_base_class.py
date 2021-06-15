from django.db import models
from core.models.core_tables import RetUUIDField

class DateColumns(models.Model, DateColumns, StatusColumn, ActorColumn):