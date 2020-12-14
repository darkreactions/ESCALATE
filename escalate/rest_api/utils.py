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

view_names = ['Actor', 'Organization', 'Status', 'Systemtool', 'SystemtoolType', 'Inventory', 'InventoryMaterial',
              'Calculation', 'CalculationDef',
              'Material', 'MaterialComposite', 'MaterialCalculationJson', 'MaterialRefnameDef',
              'MaterialType', 'Note_x', 'Person',
              'TagType', 'Property', 'PropertyDef', 'MaterialProperty', 'TypeDef',
              'ParameterDef', 'Condition', 'ConditionDef', 'ActionParameter', 'Parameter', 'WorkflowType',
              'WorkflowStep', 'WorkflowObject', 'UdfDef', 'Experiment', 'ExperimentWorkflow',
              'BillOfMaterials', 'BomMaterial']

GET_only_views = ['TypeDef']

custom_serializer_views = ['Tag', 'Note',
                           'Edocument',
                           'ExperimentMeasureCalculation',
                           'ActionDef', 'Action', 'Workflow']

perform_create_views = ['PropertyDef', "MaterialProperty"]


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
