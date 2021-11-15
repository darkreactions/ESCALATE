from django.db import models


class WorkflowBaseColumns(models.Model):
    """
    Currently I don't see common variables between all classes in workflow so this is empty.
    This should still stay to maintain Template -> Model -> Object coding sentiment and if common columns are
    created throughout workflow tables they should be added here
    """

    class Meta:
        abstract = True
