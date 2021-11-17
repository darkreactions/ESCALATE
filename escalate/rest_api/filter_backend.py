import coreapi
import coreschema

# from url_filter.integrations.drf import DjangoFilterBackend
from url_filter.integrations.drf_coreapi import CoreAPIURLFilterBackend


class CustomDjangoFilterBackend(CoreAPIURLFilterBackend):
    """
    Overrides get_schema_fields() to show filter_fields in Swagger.
    """

    def get_schema_fields(self, view):
        assert (
            coreapi is not None
        ), "coreapi must be installed to use `get_schema_fields()`"
        assert (
            coreschema is not None
        ), "coreschema must be installed to use `get_schema_fields()`"

        # append filter fields to existing fields
        fields = super().get_schema_fields(view)
        if hasattr(view, "filter_fields"):
            fields += view.filter_fields

        return [
            coreapi.Field(name=field, location="query", required=False, type="string",)
            for field in fields
        ]
