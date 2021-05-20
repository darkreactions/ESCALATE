from django.db import models

class DateColumns(models.Model):
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True

class StatusColumn(models.Model):
    status = models.ForeignKey('Status',
                               on_delete=models.DO_NOTHING,
                               db_column='status_uuid',
                               blank=True,
                               null=True,
                               related_name='%(class)s_status')
    class Meta:
        abstract = True

class ActorColumn(models.Model):
    actor = models.ForeignKey('Actor',
                              on_delete=models.DO_NOTHING,
                              db_column='actor_uuid',
                              blank=True,
                              null=True,
                              related_name='%(class)s_actor')
    class Meta:
        abstract = True