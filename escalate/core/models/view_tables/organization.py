from django.db import models
from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from core.models.core_tables import RetUUIDField
from core.models.abstract_base_models import DateColumns, StatusColumn, ActorColumn
from core.models.view_tables.generic_data import NoteTest
import uuid
from django.contrib.contenttypes.fields import GenericRelation

class Actor(DateColumns, StatusColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='actor_uuid')
    organization = models.ForeignKey('Organization',
                                     on_delete=models.DO_NOTHING,
                                     blank=True, null=True,
                                     db_column='organization_uuid', related_name='actor_organization')
    person = models.ForeignKey('Person',
                               on_delete=models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='person_uuid', related_name='actor_person')
    systemtool = models.ForeignKey('Systemtool',
                                   on_delete=models.DO_NOTHING,
                                   blank=True, null=True,
                                   db_column='systemtool_uuid',
                                   related_name='actor_systemtool')
    description = models.CharField(max_length=255, blank=True, null=True)
    

    class Meta:
        managed = False
        db_table = 'actor'

    def __str__(self):
        return "{}".format(self.description)


class ActorPref(DateColumns, ActorColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='actor_pref_uuid')
    pkey = models.CharField(
        max_length=255, blank=True, null=True)
    pvalue = models.CharField(
        max_length=255, blank=True, null=True)
    
    class Meta:
        managed = False
        db_table = 'actor_pref'

    def __str__(self):
        return f"{self.pkey} : {self.pvalue}"


class Organization(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='organization_uuid')
    description = models.CharField(max_length=255)
    full_name = models.CharField(max_length=255)
    short_name = models.CharField(max_length=255, blank=True, null=True)
    address1 = models.CharField(max_length=255, blank=True, null=True)
    address2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    state_province = models.CharField(max_length=3, blank=True, null=True)
    zip = models.CharField(max_length=255, blank=True, null=True)
    country = models.CharField(max_length=255, blank=True, null=True)
    website_url = models.CharField(max_length=255, blank=True, null=True)
    phone = models.CharField(max_length=255, blank=True, null=True)
    parent = models.ForeignKey('self', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parent_uuid',
                               related_name='organization_parent')
    parent_path = models.CharField(max_length=255, blank=True, null=True)
    note_test = GenericRelation(NoteTest)

    class Meta:
        managed = False
        db_table = 'organization'

    def __str__(self):
        return "{}".format(self.full_name)


class Person(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='person_uuid')
    first_name = models.CharField(
        max_length=255)
    last_name = models.CharField(max_length=255)
    middle_name = models.CharField(
        max_length=255, blank=True, null=True)
    address1 = models.CharField(max_length=255, blank=True, null=True)
    address2 = models.CharField(max_length=255, blank=True, null=True)
    city = models.CharField(max_length=255, blank=True, null=True)
    state_province = models.CharField(max_length=3, blank=True, null=True)
    zip = models.CharField(max_length=255, blank=True, null=True)
    country = models.CharField(max_length=255, blank=True, null=True)

    phone = models.CharField(max_length=255, blank=True, null=True)
    email = models.EmailField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    suffix = models.CharField(max_length=255, blank=True, null=True)
    organization = models.ForeignKey('Organization', models.DO_NOTHING,
                                     blank=True, null=True,
                                     db_column='organization_uuid',
                                     related_name='person_organization')
    added_organization = models.ManyToManyField(
        'Organization',
        through='Actor',
        related_name='person_added_organization')

    class Meta:
        managed = False
        db_table = 'person'

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)



class Systemtool(DateColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4,
                        db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=255, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    vendor_organization = models.ForeignKey('Organization',
                                            models.DO_NOTHING,
                                            db_column='vendor_organization_uuid',
                                            related_name='systemtool_vendor_organization')
    systemtool_type = models.ForeignKey('SystemtoolType',
                                        models.DO_NOTHING,
                                        db_column='systemtool_type_uuid',
                                        related_name='systemtool_systemtool_type')
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255,  null=True)

    class Meta:
        managed = False
        db_table = 'systemtool'

    def __str__(self):
        return "{}".format(self.systemtool_name)


class SystemtoolType(DateColumns):
    #systemtool_type_id = models.BigAutoField()
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column='systemtool_type_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'systemtool_type'

    def __str__(self):
        return self.description

