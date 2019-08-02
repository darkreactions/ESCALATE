from django.db import models
from . import Note, Document, CommonFields
from tracking import Actor
from ingredients import Aggregate

class MeasureType(CommonFields):
    pass

class Measure(CommonFields):
    measure_type = models.ForeignKey(MeasureType, on_delete=models.CASCADE)
    amount = models.FloatField()
    unit = models.CharField(max_length=255)
    data_doc = models.ForeignKey(Document, on_delete=models.CASCADE)

class Outcome(CommonFields):
    actor = models.ForeignKey(Actor, on_delete=models.CASCADE)
    measure = models.ForeignKey(Measure, on_delete=models.CASCADE)
    data_file = models.BinaryField()
    compound = models.ForeignKey(Aggregate, on_delete=models.CASCADE)
