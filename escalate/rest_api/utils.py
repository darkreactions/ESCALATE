from django.db import connection as con

import inflection


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
        "ActionSequenceType",  #'WorkflowStep', 'WorkflowObject',
        "UdfDef",
        "ExperimentTemplate",
        "ActionSequence",
        "ExperimentActionSequence",
        "ExperimentType",
        "BillOfMaterials",
        "Measure",
        "MeasureType",
        "MeasureDef",
        "OutcomeTemplate",
        "OutcomeInstance",
        "Action",
        "ActionUnit",
        "ActionDef",
        "ExperimentInstance",
        "BaseBomMaterial",
        "Vessel",
        "VesselInstance",
        "Contents",
        "Reagent",
        "ReagentMaterial",
        "ReagentMaterialValue",
        "ReagentTemplate",
        "ReagentMaterialTemplate",
        "ReagentMaterialValueTemplate",
        "DefaultValues",
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
            "action_sequence": (
                "rest_api.ActionSequenceSerializer",
                {
                    "many": True,
                },
            ),
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
        "options": {"many_to_many": ["action_sequence"]},
        "fields": {
            "action_sequence": (
                "rest_api.ActionSequenceSerializer",
                {
                    "many": True,
                },
            ),
            "bill_of_materials": (
                "rest_api.BillOfMaterialsSerializer",
                {
                    "source": "bom_experiment_instance",
                    "many": True,
                    "read_only": True,
                    "view_name": "billofmaterials-detail",
                },
            ),
            "reagents": (
                "rest_api.ReagentSerializer",
                {
                    "source": "reagent_ei",
                    "many": True,
                    "read_only": True,
                    "view_name": "reagentmaterial-detail",
                },
            ),
            "outcome_instance": (
                "rest_api.OutcomeInstanceSerializer",
                {
                    "source": "outcome_instance_experiment_instance",
                    "many": True,
                    "read_only": True,
                    "view_name": "outcomeinstance-detail",
                },
            ),
        },
    },
}

"""
    'ActionSequence': {
        'options': {
            'many_to_many': []
        },
        'fields': {
        'step': ('rest_api.WorkflowStepSerializer',
                  {
                      'source': 'workflow_step_workflow',
                      'many': True,
                      'read_only': True,
                      'view_name': 'workflowstep-detail'
                  })
        }
    },
'WorkflowObject': {
        'options': {
            'many_to_many': []
        },
        'fields': {
        'action': ('rest_api.ActionSerializer',
                    {
                        'read_only': True,
                        'view_name': 'action-detail'
                    })
        }
    },
    'WorkflowStep': {
        'options': {
            'many_to_many': ['workflow']
        },
        'fields': {
        'workflow_object': ('rest_api.WorkflowObjectSerializer',
                            {
                                'read_only': True,
                                'view_name': 'workflowobject-detail'
                            })
        }
    },
 'ReagentInstance':{
        'options': {
        },
        'fields': {
            'reagent_values': ('rest_api.ReagentInstanceSerializer',
                     {
                         'source': 'reagent_instance_value_reagent_instance',
                         'many': True,
                         'read_only': True,
                         'view_name': 'reagentinstancevalue-detail',
                     }),
        }
    },
'BomCompositeMaterial': {
        'options': {
            'many_to_many': []
        },
        'fields': {
            'mixture': ('rest_api.CompositeMaterialSerializer', 
                                {
                                    'read_only': True,
                                    'view_name': 'mixture-detail'

                                })
        }
    },
    'BomMaterial': {
        'options': {
            'many_to_many': []
        },
        'fields': {
            'bom_composite_material': ('rest_api.BomCompositeMaterialSerializer',
                                    {
                                        'source': 'bom_composite_material_bom_material',
                                        'many': True,
                                        'read_only': True,
                                        'view_name': 'bomcompositematerial-detail'
                                    }
        )
        }
    },
'Action': {
        'options': {
             'many_to_many': []
        },
        'fields': {
            'action_unit': ('rest_api.ActionUnitSerializer', 
                                {
                                    'read_only': True,
                                    'many': True, 
                                    'source': 'action_unit_action',
                                    'view_name': 'actionunit-detail'
                                }),
                                

        }
    },
'ExperimentWorkflow': {
        'options': {
            'many_to_many': []
        },
        'fields': {
            'workflow': ('rest_api.WorkflowSerializer',
                        {
                            #'read_only': True,
                            'view_name': 'workflow-detail'
                        })
        }
    },

    'ActionDef': {
        'options': {
             'many_to_many': []
        },
        'fields': {
            'parameter_def': ('rest_api.ParameterDefSerializer', 
                                {
                                    'read_only': True,
                                    'many': True, 
                                    #'source': 'parameter_action',
                                    'view_name': 'parameterdef-detail'
                                })
        }
    },
"""
