from django.db import models
from . import Note, Document, CommonFields
from .tracking import Actor, Status
from .measures import Outcome

class Workflow(CommonFields):
    actor = models.ForeignKey(Actor, on_delete=models.CASCADE)
    status = models.ForeignKey(Status, on_delete=models.CASCADE)
    document = models.ForeignKey(Document, on_delete=models.CASCADE)

class Experiment(CommonFields):
    parent_experiment = models.ForeignKey('self', on_delete=models.CASCADE)
    status = models.ForeignKey(Status, on_delete=models.CASCADE)
    outcome = models.ForeignKey(Outcome, on_delete=models.CASCADE)
