from collections.abc import Iterable
from django.db import models

import json
from django.core.exceptions import ValidationError
import csv
from django.contrib.postgres.fields import ArrayField
from django.forms import (
    MultiWidget,
    TextInput,
    Select,
    MultiValueField,
    CharField,
    ChoiceField,
)
from core.custom_types import Val
from core.validators import ValValidator
from core.widgets import ValFormField


"""
v_type_uuid uuid, 0
v_unit character varying, 1
v_text character varying, 2
v_text_array character varying[], 3
v_int bigint, 4
v_int_array bigint[], 5
v_num numeric, 6
v_num_array numeric[], 7
v_edocument_uuid uuid, 8
v_source_uuid uuid, 9
v_bool boolean, 10
v_bool_array boolean[] 11
"""


class CustomArrayField(ArrayField):
    def _from_db_value(self, value, expression, connection):

        if value is None:
            return value
        value = list(
            csv.reader([value[1:-1]], delimiter=",", quotechar='"', escapechar="\\")
        )[0]
        return [
            self.base_field.from_db_value(item, expression, connection)
            for item in value
        ]


class ValField(models.TextField):
    description = "Data representation"
    formfield = ValFormField()

    def __init__(self, *args, **kwargs):
        self.list = kwargs.pop("list", False)
        super().__init__(*args, **kwargs)

    def deconstruct(self):
        name, path, args, kwargs = super().deconstruct()

        return name, path, args, kwargs

    # def db_type(self, connection):
    #    return 'val'

    def from_db_value(self, value, expression, connection):
        if value is None:
            return Val(None, None, None, null=True)

        return Val.from_db(value)

    def to_python(self, value):
        if isinstance(value, Val):
            return value
        elif isinstance(value, (list, tuple)):
            return Val(*value)

        if value is None or value == "":
            return value

        return Val.from_db(value)

    def get_prep_value(self, value):
        if isinstance(value, dict):
            value = Val.from_dict(value)
        elif value == None or value == "":
            value = Val(None, None, None, null=True)
        return value.to_db()

    def get_db_prep_value(self, value, connection, prepared=False):
        value = super().get_db_prep_value(value, connection, prepared)
        return value

    def get_db_prep_save(self, value, connection, prepared=False):
        value = super().get_db_prep_save(value, connection)
        return value

    def value_from_object(self, obj):
        obj = super().value_from_object(obj)
        return obj

    def formfield(self, **kwargs):
        # This is a fairly standard way to set up some defaults
        # while letting the caller override them.
        defaults = {"form_class": ValFormField}
        defaults.update(kwargs)
        return super().formfield(**defaults)


# enum choices for {property(_def), material} class choices
# these are enum types in postgres, so will be shortened to ints there.
# they are defined in prod_tables.sql
PROPERTY_CLASS_CHOICES = (("nominal", "nominal"), ("actual", "actual"))
PROPERTY_DEF_CLASS_CHOICES = (("intrinsic", "intrinsic"), ("extrinsic", "extrinsic"))
MATERIAL_CLASS_CHOICES = (
    ("template", "template"),
    ("model", "model"),
    ("object", "object"),
)
