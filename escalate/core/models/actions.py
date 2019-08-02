from django.db import models
from . import Note, Document, CommonFields
from .measures import Measure
from .tracking import Actor
from .ingredients import Ingredient, Aggregate


class ActionDef(CommonFields):
    category = models.CharField(max_length=255)

class Action(CommonFields):
    action_def = models.ForeignKey(ActionDef, on_delete=models.CASCADE)
    measure = models.ForeignKey(Measure, on_delete=models.CASCADE)
    performer = models.ForeignKey(Actor, on_delete=models.CASCADE)

class ActionPlan(CommonFields):
    experiment = models.ForeignKey(Document, on_delete=models.CASCADE)
    action = models.ForeignKey(Action, on_delete=models.CASCADE)
    seq = models.IntegerField()

class ActionIngredient(CommonFields):
    action = models.ForeignKey(Action, on_delete=models.CASCADE)
    aggregate = models.ForeignKey(Aggregate, on_delete=models.CASCADE)
    ingredient = models.ForeignKey(Ingredient, on_delete=models.CASCADE)
    measure = models.ForeignKey(Measure, on_delete=models.CASCADE)
