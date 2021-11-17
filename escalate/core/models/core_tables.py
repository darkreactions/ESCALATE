# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey has `on_delete` set to the desired behavior.
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from datetime import datetime
from django.utils.timezone import now
import uuid
from django_extensions.db.fields import AutoSlugField
from core.utils_no_dependencies import rgetattr
import unicodedata
import re

# managed_value = False
managed_tables = True
managed_views = False


class RetUUIDField(models.UUIDField):
    """A UUID field which populates with the UUID from Postgres on CREATE.

    **Use this instead of models.UUIDField**

    Our tables are managed by postgres, not django. Without this field,
    django would have no direct way of knowing the UUID of newly created resources,
    which would lead to errors.
    """

    db_returning = True

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)


def custom_slugify(content, allow_unicode=False):
    if content == None:
        return ""
    # modified from https://docs.djangoproject.com/en/3.0/_modules/django/utils/text/
    if allow_unicode:
        content = unicodedata.normalize("NFKC", content)
    else:
        content = (
            unicodedata.normalize("NFKD", content)
            .encode("ascii", "ignore")
            .decode("ascii")
        )
    content = content.lower()
    # matches chars that are not a word char or not whitespace or not a hyphen char and replaces with hyphen
    # catches stuff like quotes, commas, parantheses, etc
    # materials identifier has weird chars so commented out line below
    # content = re.sub(r'[^\w\s-]', '-', content)
    # matches 1 or more hypens and/or whitespace and replaces with one hyphen
    content = re.sub(r"[-\s]+", "-", content)
    return content.strip("-_")


class SlugField(AutoSlugField):
    def __init__(self, *args, **kwargs):
        if kwargs.get("slugify_function", None) == None:
            kwargs["slugify_function"] = lambda s: custom_slugify(s, allow_unicode=True)
        super().__init__(*args, **kwargs)

    def get_slug_fields(self, model_instance, lookup_value):
        if callable(lookup_value):
            # A function has been provided
            return "%s" % lookup_value(model_instance)

        lookup_value_path = ".".join(lookup_value.split("__"))
        attr = rgetattr(model_instance, lookup_value_path, None)

        if attr.__class__.__name__ == "ManyRelatedManager":
            return "-".join(attr.all())
        if callable(attr):
            return "%s" % attr()
        return str(attr) if attr != None else ""


class TypeDef(models.Model):

    uuid = RetUUIDField(primary_key=True, default=uuid.uuid4, db_column="type_def_uuid")

    category = models.CharField(
        max_length=255, blank=True, null=True, db_column="category"
    )
    description = models.CharField(
        max_length=255, blank=True, null=True, db_column="description"
    )
    add_date = models.DateTimeField(auto_now_add=True)
    mod_date = models.DateTimeField(auto_now=True)
    internal_slug = SlugField(
        populate_from=[
            "category",
            "description",
        ],
        overwrite=True,
        max_length=255,
    )

    def __str__(self):
        return self.description
