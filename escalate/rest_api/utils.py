import re

from django.db import connection as con


def get_val(val):
    """breaks val tuple into constituent parts"""
    cur = con.cursor()
    cur.execute(f"select get_val ('{val}'::val);")
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


misc_views = set(['MaterialCalculationJson', 'Note_x'])

core_views = set(['Actor', 'Organization', 'Status', 'Systemtool',
                  'SystemtoolType', 'Inventory', 'InventoryMaterial',
                  'Calculation', 'CalculationDef', 'Material',
                  'CompositeMaterial', 'MaterialRefnameDef', 'MaterialType',
                  'Person', 'Tag', 'TagType', 'Property', 'PropertyDef',
                  'TypeDef', 'ParameterDef', 'Condition', 'ConditionDef',
                  'ActionParameter', 'Parameter', 'WorkflowType', 'WorkflowStep',
                  'WorkflowObject', 'UdfDef', 'Experiment', 'ExperimentWorkflow',
                  'BillOfMaterials', 'BomMaterial', 'Measure', 'MeasureType', 'Outcome'])

GET_only_views = set(['TypeDef'])

unexposed_views = set(['TagAssign', 'Note', 'Edocument'])

custom_serializer_views = set(['ExperimentMeasureCalculation',
                               'ActionDef', 'Action', 'Workflow'])

perform_create_views = set(['PropertyDef', 'MaterialProperty'])

# Set of models for rest_api/serializers.py
rest_serializer_views = core_views | misc_views | perform_create_views

# Set of models for all exposed urls in rest_api/urls.py
rest_exposed_url_views = core_views | custom_serializer_views | perform_create_views

# Set of models for all nested urls in rest_api/urls.py
rest_nested_url_views = (core_views | misc_views | custom_serializer_views |
                         perform_create_views | unexposed_views)

# Set of models that have viewsets in rest_api/viewsets.py
rest_viewset_views = (core_views | misc_views | custom_serializer_views |
                      perform_create_views | unexposed_views)


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
