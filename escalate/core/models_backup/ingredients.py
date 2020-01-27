from django.db import models
from . import Note, Document, CommonFields
from .tracking import Actor
from .descriptors import Descriptor


class IngredientType(CommonFields):
    pass

class IngredientRef(CommonFields):
    ingredient_type = models.ForeignKey(IngredientType, on_delete=models.CASCADE)

class Aggregate(CommonFields):
    actor = models.ForeignKey(Actor, on_delete=models.CASCADE)

class Ingredient(CommonFields):
    ingredient_ref = models.ForeignKey(IngredientRef, on_delete=models.CASCADE)
    actor = models.ForeignKey(Actor, on_delete=models.CASCADE)
    descriptor = models.ManyToManyField(Descriptor)
    aggregate = models.ForeignKey(Aggregate, on_delete=models.CASCADE)
