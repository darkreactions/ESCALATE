from django.db import models
from core.models.core_tables import RetUUIDField
#from django.db.models import Model, ForeignKey
from auto_prefetch import Model, ForeignKey

class Actor(Model):
    uuid = RetUUIDField(primary_key=True, db_column='actor_uuid')
    organization = ForeignKey('Organization',
                                     on_delete=models.DO_NOTHING,
                                     blank=True, null=True,
                                     db_column='organization_uuid', related_name='actor_organization')
    person = ForeignKey('Person',
                               on_delete=models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='person_uuid', related_name='actor_person')
    systemtool = ForeignKey('Systemtool',
                                   on_delete=models.DO_NOTHING,
                                   blank=True, null=True,
                                   db_column='systemtool_uuid',
                                   related_name='actor_systemtool')
    description = models.CharField(max_length=255, blank=True, null=True)
    status = ForeignKey('Status', on_delete=models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='status_uuid',
                               related_name='actor_status')
    status_description = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    org_full_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Organization Full Name')
    org_short_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Organization Short Name')

    person_last_name = models.CharField(
        max_length=255, blank=True, null=True, verbose_name='Person Lastname')
    person_first_name = models.CharField(
        max_length=255, blank=True, null=True)
    person_last_first = models.CharField(
        max_length=255, blank=True, null=True)
    person_org = models.CharField(max_length=255, blank=True, null=True)
    systemtool_name = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_description = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_type = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_vendor = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_model = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_serial = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_version = models.CharField(
        max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'vw_actor'

    def __str__(self):
        return "{}".format(self.description)


class ActorPref(Model):
    uuid = RetUUIDField(primary_key=True, db_column='actor_pref_uuid')
    actor_uuid = ForeignKey('Actor',
                               on_delete=models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='actor_uuid', related_name='actor_pref_actor')
    pkey = models.CharField(
        max_length=255, blank=True, null=True)
    pvalue = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    class Meta:
        managed = False
        db_table = 'vw_actor_pref'

    def __str__(self):
        return f"{self.pkey} : {self.pvalue}"


class Organization(Model):
    uuid = RetUUIDField(primary_key=True, db_column='organization_uuid')
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

    parent = ForeignKey('self', models.DO_NOTHING,
                               blank=True, null=True,
                               db_column='parent_uuid',
                               related_name='organization_parent')
    parent_org_full_name = models.CharField(
        max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_organization'

    def __str__(self):
        return "{}".format(self.full_name)


class Person(Model):
    uuid = RetUUIDField(primary_key=True, db_column='person_uuid')
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
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    organization = ForeignKey('Organization', models.DO_NOTHING,
                                     blank=True, null=True,
                                     db_column='organization_uuid',
                                     related_name='person_organization')
    organization_full_name = models.CharField(max_length=255,
                                              blank=True, null=True)
    added_organization = models.ManyToManyField(
        'Organization', through='Actor', related_name='person_added_organization')

    class Meta:
        managed = False
        db_table = 'vw_person'

    def __str__(self):
        return "{} {}".format(self.first_name, self.last_name)


class Systemtool(Model):
    uuid = RetUUIDField(primary_key=True,
                        db_column='systemtool_uuid')
    systemtool_name = models.CharField(max_length=255, null=True)
    description = models.CharField(max_length=255, blank=True, null=True)
    vendor_organization = ForeignKey('Organization',
                                            models.DO_NOTHING,
                                            db_column='vendor_organization_uuid',
                                            related_name='systemtool_vendor_organization')
    organization_fullname = models.CharField(
        max_length=255, blank=True, null=True)
    systemtool_type = ForeignKey('SystemtoolType',
                                        models.DO_NOTHING,
                                        db_column='systemtool_type_uuid',
                                        related_name='systemtool_systemtool_type')
    systemtool_type_description = models.CharField(
        max_length=255, blank=True, null=True)
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255,  null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_systemtool'

    def __str__(self):
        return "{}".format(self.systemtool_name)


class SystemtoolType(Model):
    #systemtool_type_id = models.BigAutoField()
    uuid = RetUUIDField(primary_key=True, db_column='systemtool_type_uuid')
    description = models.CharField(max_length=255, blank=True, null=True)
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)

    class Meta:
        managed = False
        db_table = 'vw_systemtool_type'

    def __str__(self):
        return self.description

