from django.db import models
from . import Note, Document, CommonFields
from tracking import Actor, Status

class DescriptorClass(CommonFields):
    pass

class DescriptorValue(CommonFields):
    num_value = models.FloatField()
    blob_value = models.BinaryField()

class Descriptor(CommonFields):
    #ingredient = models.ForeignKey(Ingredient, on_delete=models.CASCADE)
    descriptor_class = models.ForeignKey(DescriptorClass, on_delete=models.CASCADE)
    descriptor_value = models.ForeignKey(DescriptorValue, on_delete=models.CASCADE)
    actor = models.ForeignKey(Actor, on_delete=models.CASCADE)
    status = models.ForeignKey(Status, on_delete=models.CASCADE)
    version = models.CharField(max_length=255)
