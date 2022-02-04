from django.db import models
from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from core.models.core_tables import RetUUIDField, SlugField
from core.models.base_classes import (
    DateColumns,
    StatusColumn,
    ActorColumn,
    DescriptionColumn,
    AddressColumns,
)
from core.models.view_tables.generic_data import Status
import uuid

# from django.contrib.contenttypes.fields import GenericRelation


managed_tables = True
managed_views = False


class Actor(DateColumns, StatusColumn, DescriptionColumn):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="actor_uuid")
    organization = models.ForeignKey(
        "Organization",
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        db_column="organization_uuid",
        related_name="actor_organization",
    )
    person = models.ForeignKey(
        "Person",
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        db_column="person_uuid",
        related_name="actor_person",
    )
    systemtool = models.ForeignKey(
        "Systemtool",
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        db_column="systemtool_uuid",
        related_name="actor_systemtool",
    )
    internal_slug = SlugField(
        populate_from=[
            "person__internal_slug",
            "organization__internal_slug",
            "systemtool__internal_slug",
        ],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        rep = list(
            filter(
                lambda x: x != "None",
                (
                    str(self.organization),
                    str(self.person),
                    str(self.systemtool),
                    str(self.description),
                ),
            )
        )
        return "-".join(rep)
        # return "{}".format()


class ActorPref(DateColumns, ActorColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="actor_pref_uuid"
    )
    pkey = models.CharField(max_length=255, blank=True, null=True)
    pvalue = models.CharField(max_length=255, blank=True, null=True)
    internal_slug = SlugField(
        populate_from=["pkey", "pvalue"], overwrite=True, max_length=255
    )

    def __str__(self):
        return f"{self.pkey} : {self.pvalue}"


class Organization(DateColumns, AddressColumns, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="organization_uuid"
    )
    full_name = models.CharField(max_length=255)
    short_name = models.CharField(max_length=255, blank=True, null=True)
    website_url = models.CharField(max_length=255, blank=True, null=True)
    parent = models.ForeignKey(
        "self",
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        db_column="parent_uuid",
        related_name="organization_parent",
    )
    parent_path = models.CharField(max_length=255, blank=True, null=True)
    internal_slug = SlugField(
        populate_from=["full_name", "short_name"], overwrite=True, max_length=255
    )

    def __str__(self):
        return "{}".format(self.full_name)

    def add_person(self, person, *args):
        people_to_add = [person, *args]
        for p in people_to_add:
            assert isinstance(p, Person), f"{p} is not a Person instance"

        active_status = Status.objects.get(description="active")
        for person_to_add in people_to_add:
            fields = {
                "person": person_to_add,
                "organization": self,
                "description": f"{str(person_to_add)} ({str(self)})",
                "status": active_status,
            }
            Actor.objects.get_or_create(**fields)

    def remove_person(self, person, *args):
        people_to_remove = [person, *args]
        for p in people_to_remove:
            assert isinstance(p, Person), f"{p} is not a Person instance"

        Actor.objects.filter(organization=self.pk, person__in=people_to_remove).delete()


class Person(DateColumns, AddressColumns):
    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="person_uuid")
    email = models.EmailField(max_length=255, blank=True, null=True)
    title = models.CharField(max_length=255, blank=True, null=True)
    first_name = models.CharField(max_length=255, blank=True, null=True)
    middle_name = models.CharField(max_length=255, blank=True, null=True)
    last_name = models.CharField(max_length=255, blank=True, null=True)
    suffix = models.CharField(max_length=255, blank=True, null=True)
    organization = models.ForeignKey(
        "Organization",
        on_delete=models.SET_NULL,
        blank=True,
        null=True,
        db_column="organization_uuid",
        related_name="person_organization",
    )
    added_organization = models.ManyToManyField(
        "Organization", through="Actor", related_name="person_added_organization"
    )
    internal_slug = SlugField(
        populate_from=["first_name", "middle_name", "last_name"],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return " ".join(
            list(
                filter(
                    lambda s: s != None and s != "",
                    [self.first_name, self.middle_name, self.last_name],
                )
            )
        )

    def add_to_organization(self, organization, *args):
        organizations_to_add_to = [organization, *args]
        for org in organizations_to_add_to:
            assert isinstance(
                org, Organization
            ), f"{org} is not an Organization instance"

        active_status = Status.objects.get(description="active")
        for organization in organizations_to_add_to:
            fields = {
                "person": self,
                "organization": organization,
                "description": f"{str(self)} ({str(organization)})",
                "status": active_status,
            }
            Actor.objects.get_or_create(**fields)

    def remove_from_organization(self, organization, *args):
        organizations_to_remove_from = [organization, *args]
        for org in organizations_to_remove_from:
            assert isinstance(
                org, Organization
            ), f"{org} is not an Organization instance"

        Actor.objects.filter(
            person=self.pk, organization__in=organizations_to_remove_from
        ).delete()


class Systemtool(DateColumns, DescriptionColumn):
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="systemtool_uuid"
    )
    systemtool_name = models.CharField(max_length=255, null=True)
    vendor_organization = models.ForeignKey(
        "Organization",
        null=True,
        on_delete=models.CASCADE,
        db_column="vendor_organization_uuid",
        related_name="systemtool_vendor_organization",
    )
    systemtool_type = models.ForeignKey(
        "SystemtoolType",
        null=True,
        on_delete=models.CASCADE,
        db_column="systemtool_type_uuid",
        related_name="systemtool_systemtool_type",
    )
    model = models.CharField(max_length=255, blank=True, null=True)
    serial = models.CharField(max_length=255, blank=True, null=True)
    ver = models.CharField(max_length=255, null=True)
    internal_slug = SlugField(
        populate_from=["systemtool_name"], overwrite=True, max_length=255
    )

    def __str__(self):
        return "{}".format(self.systemtool_name)


class SystemtoolType(DateColumns, DescriptionColumn):
    # systemtool_type_id = models.BigAutoField()
    uuid = RetUUIDField(
        primary_key=True, default=uuid.uuid4, db_column="systemtool_type_uuid"
    )

    def __str__(self):
        return self.description
