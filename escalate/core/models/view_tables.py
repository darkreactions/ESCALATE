from django.db import models


managed_value = False


class ViewInventory(models.Model):
    inventory = models.OneToOneField(
        'Inventory', on_delete=models.DO_NOTHING, primary_key=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    material = models.ForeignKey(
        'Material', on_delete=models.DO_NOTHING, blank=True, null=True)
    actor = models.ForeignKey(
        'Actor', on_delete=models.DO_NOTHING, blank=True, null=True)
    part_no = models.CharField(max_length=255, blank=True, null=True)
    create_dt = models.DateTimeField(blank=True, null=True)
    mod_date = models.DateTimeField(auto_now=True)
    measure = models.ForeignKey(
        'Measure', on_delete=models.DO_NOTHING, blank=True, null=True)
    amount = models.FloatField(blank=True, null=True)
    unit = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = managed_value
        db_table = 'vw_inventory'
