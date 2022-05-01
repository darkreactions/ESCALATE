import inflection
from urllib.parse import urlparse
from django.urls import resolve


def get_object_from_url(url, model):
    path = urlparse(url)[2]  # get path of the url
    match = resolve(path)
    model_obj = model.objects.get(uuid=match.kwargs["pk"])
    return model_obj


def camel_case(text):
    return inflection.camelize(text, False)


def snake_case(text):
    return inflection.underscore(text)


def dasherize(text):
    return inflection.dasherize(snake_case(text))


def camel_case_uuid(text):
    text = camel_case(text)
    # return '_'.join([text, 'uuid'])
    return text


misc_views = set(["NoteX"])

excluded_fields = ["internal_slug"]

core_views = set(
    [
        "Actor",
        "Organization",
        "Status",
        "Systemtool",
        "SystemtoolType",
        "Inventory",
        "InventoryMaterial",
        "Material",
        "Mixture",
        "MaterialIdentifierDef",
        "MaterialIdentifier",
        "MaterialType",
        "Person",
        "Tag",
        "TagType",
        "PropertyTemplate",
        "UnitType",
        "TypeDef",
        "ParameterDef",
        "UdfDef",
        "ExperimentTemplate",
        "Type",
        "BillOfMaterials",
        "OutcomeTemplate",
        "Outcome",
        "Action",
        "ActionUnit",
        "ActionDef",
        "ExperimentInstance",
        "BaseBomMaterial",
        "Vessel",
        "VesselInstance",
        "VesselType",
        "Contents",
        "Reagent",
        "ReagentMaterial",
        # "ReagentMaterialValue",
        "ReagentTemplate",
        "ReagentMaterialTemplate",
        # "ReagentMaterialValueTemplate",
        "DefaultValues",
        "DescriptorTemplate",
        "MolecularDescriptor",
        "ExperimentDescriptor",
        "ActionTemplate",
        "VesselTemplate",
    ]
)

# Views that are a combination of multiple tables, used to be postgres views. Should be changed to something else
combined_views = set(
    [
        "CompositeMaterialProperty",
        "MaterialTypeAssign",
        "ConditionCalculationDefAssign",
        "ActionParameterDefAssign",
        "MaterialProperty",
    ]
)

experiment_views = set(
    ["ActionDef", "BomMaterial", "Mixture", "Material", "ParameterDef"]
)

GET_only_views = set(["TypeDef"])

unexposed_views = set(["TagAssign", "Note", "Edocument", "Property", "Parameter"])

custom_serializer_views = set(
    [
        "BomMaterial",
        "BomCompositeMaterial",
    ]
)

# Viewsets that are not associated with a model exclusively
# non_model_views = set(['Experiment', 'ExperimentTemplate'])
non_model_views = set()

perform_create_views = set(
    [
        "PropertyTemplate",
    ]
)

# Set of models for rest_api/serializers.py
rest_serializer_views = core_views | misc_views | perform_create_views

# Set of models for all exposed urls in rest_api/urls.py
rest_exposed_url_views = (
    core_views | custom_serializer_views | perform_create_views | non_model_views
)

# Set of models for all nested urls in rest_api/urls.py
rest_nested_url_views = (
    core_views
    | misc_views
    | custom_serializer_views
    | perform_create_views
    | unexposed_views
)

# Set of models that have viewsets in rest_api/viewsets.py
rest_viewset_views = (
    core_views
    | misc_views
    | custom_serializer_views
    | perform_create_views
    | unexposed_views
)

rest_experiment_views = experiment_views


def docstring(docstr, sep="\n"):
    """
    Decorator: Append to a function's docstring.
    """

    def _decorator(func):
        if func.__doc__ == None:
            func.__doc__ = docstr
        else:
            func.__doc__ = sep.join([func.__doc__, docstr])
        return func

    return _decorator


expandable_fields = {
    "BillOfMaterials": {
        "options": {"many_to_many": []},
        "fields": {
            "bom_material": (
                "rest_api.BomMaterialSerializer",
                {
                    "source": "bom_material_bom",
                    "many": True,
                    "read_only": True,
                    "view_name": "bommaterial-detail",
                },
            )
        },
    },
    "ExperimentTemplate": {
        "options": {"many_to_many": ["action_sequence"]},
        "fields": {
            "bill_of_materials": (
                "rest_api.BillOfMaterialsSerializer",
                {
                    "source": "bom_experiment",
                    "many": True,
                    "read_only": True,
                    "view_name": "billofmaterials-detail",
                },
            ),
            "outcome_template": (
                "rest_api.OutcomeTemplateSerializer",
                {
                    "source": "outcome_experiment",
                    "many": True,
                    "read_only": True,
                    "view_name": "outcometemplate-detail",
                },
            ),
        },
    },
    "ExperimentInstance": {
        "options": {},
        "fields": {
            "action": (
                "rest_api.ActionSerializer",
                {
                    "source": "action_ei",
                    "many": True,
                    "read_only": True,
                    "view_name": "action-detail",
                },
            ),
            "reagent": (
                "rest_api.ReagentSerializer",
                {
                    "source": "reagent_ei",
                    "many": True,
                    "read_only": True,
                    "view_name": "reagent-detail",
                },
            ),
            "outcome": (
                "rest_api.OutcomeSerializer",
                {
                    "source": "outcome_instance_experiment_instance",
                    "many": True,
                    "read_only": True,
                    "view_name": "outcome-detail",
                },
            ),
        },
    },
    "Reagent": {
        "options": {},
        "fields": {
            "reagent_material": (
                "rest_api.ReagentMaterialSerializer",
                {
                    "source": "reagent_material_r",
                    "many": True,
                    "read_only": True,
                    "view_name": "reagentmaterial-detail",
                },
            ),
            "property": (
                "rest_api.PropertySerializer",
                {
                    "source": "property_r",
                    "many": True,
                    "read_only": True,
                    "view_name": "property-detail",
                },
            ),
        },
    },
    "ReagentMaterial": {
        "options": {},
        "fields": {
            "property": (
                "rest_api.PropertySerializer",
                {
                    "source": "property_rm",
                    "many": True,
                    "read_only": True,
                    "view_name": "property-detail",
                },
            )
        },
    },
}


# Endpoints should be filtered based on lab selected and permissions of the user
# Remove delete for selected models

# Write a check_permission() function to see if a row can be modified


def check_permission(user, row):
    pass