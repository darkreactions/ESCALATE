from django.db import connection as con


def get_val(val):
    """Breaks val tuple into constituent parts
    Currently unused, supplanted by core.custom_types.Val
    """
    cur = con.cursor()
    cur.execute(f"select get_val (%s::val);", [val])
    result = cur.fetchone()
    val_type = val_unit = val_val = None
    if result is not None:
        tuple_str = result[0]
        val_type, val_unit, val_val = tuple_str.strip(')(').split(',')
    return val_type, val_unit, val_val


def camel_case(text):
    data = text.lower()
    if 'view' in data[:4]:
        data = data[4:]
    return data


def snake_case(text):
    components = text.split('_')
    return ''.join(x.title() for x in components)


def camel_case_uuid(text):
    text = camel_case(text)
    # return '_'.join([text, 'uuid'])
    return text


misc_views = set(['NoteX'])

core_views = set(['Actor', 'Organization', 'Status', 'Systemtool',
                  'SystemtoolType', 'Inventory', 'InventoryMaterial',
                  'Calculation', 'CalculationDef', 'Material',
                  'CompositeMaterial', 'CompositeMaterialProperty', 'MaterialIdentifierDef', 'MaterialIdentifier',
                  'MaterialType', 'MaterialTypeAssign',
                  'Person', 'Tag', 'TagType', 'Property', 'PropertyDef', 'UnitType',
                  'TypeDef', 'ParameterDef', 'Condition', 'ConditionDef', 'ConditionCalculationDefAssign',
                  'ActionParameter', 'ActionParameterDefAssign', 'Parameter', 'WorkflowType', 'WorkflowStep', 
                  'WorkflowObject', 'UdfDef', 'Experiment', 'ExperimentWorkflow', #'ExperimentParameter',
                  'BillOfMaterials', 'BomMaterial', 'BomCompositeMaterial', 'Measure', 'MeasureType', 'MeasureDef', 'Outcome'])

experiment_views = set(['ActionDef', 'BomMaterial', 'CompositeMaterial', 'Material', 'ParameterDef'])

GET_only_views = set(['TypeDef'])

unexposed_views = set(['TagAssign', 'Note', 'Edocument'])

custom_serializer_views = set(['ActionDef', 'Action', 'Workflow', 'WorkflowActionSet'])

# Viewsets that are not associated with a model exclusively
non_model_views = set(['Experiment', 'ExperimentTemplate'])

perform_create_views = set(['PropertyDef', 'MaterialProperty'])

# Set of models for rest_api/serializers.py
rest_serializer_views = core_views | misc_views | perform_create_views

# Set of models for all exposed urls in rest_api/urls.py
rest_exposed_url_views = core_views | custom_serializer_views | perform_create_views | non_model_views

# Set of models for all nested urls in rest_api/urls.py
rest_nested_url_views = (core_views | misc_views | custom_serializer_views |
                         perform_create_views | unexposed_views)

# Set of models that have viewsets in rest_api/viewsets.py
rest_viewset_views = (core_views | misc_views | custom_serializer_views |
                      perform_create_views | unexposed_views)

rest_experiment_views = (experiment_views)

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
    'Action': {
        'options': {
             'many_to_many': []
        },
        'fields': {
            'parameter': ('rest_api.ActionParameterSerializer', 
                                {
                                    'read_only': True,
                                    'many': True, 
                                    'source': 'action_parameter_action',
                                    'view_name': 'actionparameter-detail'
                                })
        }
    },
    'BomCompositeMaterial': {
        'options': {
            'many_to_many': []
        },
        'fields': {
            'composite_material': ('rest_api.CompositeMaterialSerializer', 
                                {
                                    'read_only': True,
                                    'view_name': 'compositematerial-detail'

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
    'BillOfMaterials': {
        'options': {
            'many_to_many': []
        },
        'fields': {
        'bom_material': ('rest_api.BomMaterialSerializer',
                            {
                             'source': 'bom_material_bom',
                             'many': True,
                             'read_only': True,
                             'view_name': 'bommaterial-detail'   
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
    'Workflow': {
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
    'ExperimentWorkflow': {
        'options': {
            'many_to_many': []
        },
        'fields': {
            'workflow': ('rest_api.WorkflowSerializer',
                        {
                            'read_only': True,
                            'view_name': 'workflow-detail'
                        })
        }
    },
    'Experiment': {
        'options': {
            'many_to_many': ['workflow']
        },
        'fields': {
            'workflow': ('rest_api.WorkflowSerializer',
                     {
                         'many': True,
                     }),
            'bill_of_materials': ('rest_api.BillOfMaterialsSerializer',
                                {
                                    'source': 'bom_experiment',
                                    'many': True,
                                    'read_only': True,
                                    'view_name': 'billofmaterials-detail'
                                }),
            'outcome': ('rest_api.OutcomeSerializer',
                        {
                            'source': 'outcome_experiment',
                            'many': True,
                            'read_only': True,
                            'view_name': 'outcome-detail'
                        })
        }
        
    }

}
