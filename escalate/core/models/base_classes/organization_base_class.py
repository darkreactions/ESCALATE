from django.db import models


class OrganizationBaseColumns(models.Model):
    """
    Currently I don't see common variables between all classes in organization_data so this is empty.
    This should still stay to maintain Template -> Model -> Object coding sentiment and if common columns are
    created throughout organization tables they should be added here
    """

    class Meta:
        abstract = True


class AddressColumns(models.Model):
    address1 = models.CharField(max_length=255, blank=True, null=True)
    address2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    state_province = models.CharField(max_length=3, blank=True, null=True)
    zip = models.CharField(max_length=255, blank=True, null=True)
    country = models.CharField(max_length=255, blank=True, null=True)
    phone = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        abstract = True
